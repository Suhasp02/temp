# DDS Framework Presentation Repository

## Overview
This repository contains a comprehensive PowerPoint presentation and documentation for the **DDS (Data Distribution System) PySpark Ingestion Framework**, created from the **DDS_Framework 5.zip** contents.

## 📊 Main Deliverable
**[DDS_Framework_Architecture_Presentation.pptx](./DDS_Framework_Architecture_Presentation.pptx)**
- 10-slide professional presentation
- Complete architecture flowchart
- Design documentation with diagrams
- Framework component details
- Execution flow and configuration model

## 📁 Files Included

### Presentation & Diagrams
- **DDS_Framework_Architecture_Presentation.pptx** - Main PowerPoint presentation (39 KB)
- **architecture_diagram.svg** - Professional architecture diagram (9.2 KB)
- **DDS_Framework_Flowchart.mmd** - Mermaid flowchart source (editable)

### Documentation
- **DDS_FRAMEWORK_DELIVERABLES.md** - Complete summary of all deliverables
- **PRESENTATION_GUIDE.md** - Slide-by-slide guide to the presentation
- **DDS_Framework_Architecture.md** - Complete architecture documentation

## 🎯 Quick Start
1. **View the presentation**: Open `DDS_Framework_Architecture_Presentation.pptx`
2. **Read the guide**: Check `PRESENTATION_GUIDE.md` for slide details
3. **Review documentation**: See `DDS_Framework_Architecture.md` for technical details

## 🔍 What's Covered

### Framework Architecture
- **Launcher Component**: Python orchestrator without SparkSession
- **Ingestion Job**: PySpark application with Hive support
- **Supporting Modules**: Logging and audit utilities

### Key Features
- ✅ Automatic business date resolution
- ✅ Robust concurrency handling
- ✅ Dynamic partitioning support
- ✅ Unified logging infrastructure
- ✅ Comprehensive audit trail
- ✅ SQL-only operations (CTAS/INSERT)
- ✅ HDFS configuration per user

### Execution Flow
```
User → Launcher → Config → Ingestion → Date Resolution → 
Schema Discovery → [CTAS | INSERT] → Audit → Stop Spark
```

## 📖 Documentation
See **[DDS_FRAMEWORK_DELIVERABLES.md](./DDS_FRAMEWORK_DELIVERABLES.md)** for complete details on all deliverables.

## 🎨 Presentation Contents
1. Title Slide
2. Framework Overview
3. **Architecture Flowchart** (Visual)
4. Framework Components
5. Architecture Design Details
6. Data Flow Architecture
7. Execution Flow
8. Configuration Model
9. Key Features & Robustness
10. Summary

## 📦 Source Material
Based on **DDS_Framework 5.zip** containing:
- Complete framework source code
- Original documentation and diagrams
- Configuration examples
- Utility scripts

## 🚀 Framework Highlights
- **Reusable** PySpark ingestion solution
- **Scalable** design for CDP/Hive environments
- **Production-ready** with comprehensive error handling
- **Well-documented** with clear architecture
- **Concurrent-safe** with unique logs and CTAS IF NOT EXISTS

---
*Created: November 2025 | Based on DDS_Framework 5.zip*