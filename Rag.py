pdf_ai_service/
├── main.py                 # Streamlit or CLI app (optional)
├── api_server.py           # FastAPI app
├── pdf_ai_assistant.py     # Core logic (refactored functions)
├── requirements.txt
├── models/                 # Your transformer models, if local
└── data/                   # PDFs or test files


  # pdf_ai_assistant.py

import os
import tempfile
from PyPDF2 import PdfReader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from sentence_transformers import SentenceTransformer
from pymilvus import connections, FieldSchema, CollectionSchema, DataType, Collection
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import requests
from langchain_community.document_loaders import PyMuPDFLoader
from streamlit.runtime.uploaded_file_manager import UploadedFile
from langchain_core.documents import Document

embedding_model = None
reranking_model = None

def read_and_chunk_pdfs(folder_path, chunk_size=512, chunk_overlap=100):
    documents = []
    for filename in os.listdir(folder_path):
        if filename.endswith(".pdf"):
            reader = PdfReader(os.path.join(folder_path, filename))
            text = "\n".join(page.extract_text() for page in reader.pages if page.extract_text())
            documents.append(text)
    splitter = RecursiveCharacterTextSplitter(chunk_size=chunk_size, chunk_overlap=chunk_overlap)
    chunks = splitter.create_documents(documents)
    return chunks

def process_document(uploaded_file) -> list[Document]:
    temp_file = tempfile.NamedTemporaryFile("wb", suffix=".pdf", delete=False)
    temp_file.write(uploaded_file.read())
    loader = PyMuPDFLoader(temp_file.name)
    docs = loader.load()
    splitter = RecursiveCharacterTextSplitter(chunk_size=1024, chunk_overlap=100)
    chunks = splitter.split_documents(docs)
    embed_and_store(chunks)
    return chunks

def embed_and_store(chunks, collection_name='pdf_chunks1'):
    global embedding_model
    if embedding_model is None:
        embedding_model = SentenceTransformer("models/bge-large-en-v1.5")
    embeddings = embedding_model.encode([chunk.page_content for chunk in chunks], show_progress_bar=True)

    connections.connect("default", host="localhost", port="19530")

    try:
        collection = Collection(name=collection_name)
        collection.drop()
    except:
        pass

    fields = [
        FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
        FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=len(embeddings[0])),
        FieldSchema(name="text", dtype=DataType.VARCHAR, max_length=65535)
    ]
    schema = CollectionSchema(fields, description="PDF Chunks Collection")
    collection = Collection(name=collection_name, schema=schema)
    collection.load()
    data = [embeddings, [chunk.page_content for chunk in chunks]]
    collection.insert(data)

def query_and_rerank(prompt, collection_name='pdf_chunks1', top_k=5):
    global embedding_model
    if embedding_model is None:
        embedding_model = SentenceTransformer("models/bge-large-en-v1.5")
    query_embedding = embedding_model.encode([prompt])[0]

    connections.connect("default", host="localhost", port="19530")
    collection = Collection(collection_name)
    collection.load()

    results = collection.search(
        data=[query_embedding],
        anns_field="embedding",
        param={"metric_type": "L2", "params": {"nprobe": 10}},
        limit=top_k,
        output_fields=["text"]
    )
    texts = [hit.entity.get("text") for hit in results[0]]

    global reranking_model
    if reranking_model is None:
        reranking_model = AutoModelForSequenceClassification.from_pretrained("models/bge-reranker-v2-en")
        tokenizer = AutoTokenizer.from_pretrained("models/bge-reranker-v2-en")

    pairs = [(prompt, t) for t in texts]
    inputs = tokenizer(pairs, padding=True, truncation=True, return_tensors="pt")
    with torch.no_grad():
        scores = reranking_model(**inputs).logits.squeeze(-1)

    ranked_texts = [text for text, _ in sorted(zip(texts, scores), key=lambda x: x[1], reverse=True)]
    return ranked_texts

def context_specific_prompt(prompt, context):
    context_prompt = "\nYou are an assistant that answers questions strictly based on the provided context.\n"
    context_prompt += "Do not use any external knowledge or assumptions.\n\nContext:\n\"\"\"\n"
    for c in context:
        context_prompt += c + "\n"
    context_prompt += "\"\"\"\n\nQuestion:\n" + prompt + "\n\nInstructions:\n"
    context_prompt += "- Only use the information in the context.\n"
    context_prompt += "- If the answer is not in the context, respond with: \"The answer is not available in the provided context.\"\n"
    return context_prompt

def getresponse(prompt):
    data = {"prompt": prompt}
    resp = requests.post("http://chatops.sg.uobnet.com:8382/v1/text/generate", json=data, headers={"Content-Type": "application/json"}, verify=False)
    return resp.text.replace("\n", " ")


from fastapi import FastAPI, UploadFile, File
from typing import List
import shutil
import tempfile
import os

from pdf_ai_assistant import (
    read_and_chunk_pdfs,
    process_document,
    embed_and_store,
    query_and_rerank,
    context_specific_prompt,
    getresponse
)

app = FastAPI()

@app.post("/upload-pdf/")
async def upload_pdf(file: UploadFile = File(...)):
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".pdf")
    with open(temp_file.name, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    with open(temp_file.name, "rb") as buffer:
        file.file = buffer
        chunks = process_document(file)
    os.unlink(temp_file.name)
    return {"message": "PDF processed", "chunks_count": len(chunks)}

@app.post("/chunk-folder/")
def chunk_folder(folder_path: str, chunk_size: int = 512, chunk_overlap: int = 100):
    chunks = read_and_chunk_pdfs(folder_path, chunk_size, chunk_overlap)
    return {"chunks_count": len(chunks)}

@app.get("/query/")
def query(prompt: str, top_k: int = 5):
    ranked = query_and_rerank(prompt, top_k=top_k)
    return {"ranked_contexts": ranked}

@app.post("/context-prompt/")
def make_prompt(prompt: str, context: List[str]):
    full_prompt = context_specific_prompt(prompt, context)
    return {"prompt": full_prompt}

@app.post("/generate/")
def generate(prompt: str):
    response = getresponse(prompt)
    return {"response": response}


