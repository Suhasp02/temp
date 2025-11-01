# DDS Framework Presentation Deliverables

## Summary
Based on the **DDS_Framework 5.zip** contents, a comprehensive PowerPoint presentation has been prepared along with supporting documentation and diagrams.

## Deliverables

### 1. PowerPoint Presentation ⭐
**File**: `DDS_Framework_Architecture_Presentation.pptx`

A 10-slide professional presentation covering:
- Title slide with framework branding
- Framework overview and purpose
- **Detailed architecture flowchart** showing complete execution flow
- Framework components breakdown
- Architecture design details
- Data flow architecture diagram
- Step-by-step execution flow
- Configuration model specifications
- Key features and robustness measures
- Summary and benefits

**Features**:
- Professional color-coded diagrams
- Visual flowcharts with decision points
- Clear component separation
- Data flow illustrations
- Easy to understand for both technical and business audiences

### 2. Architecture Documentation
**File**: `DDS_Framework_Architecture.md`

Complete architecture documentation including:
- Overview of the framework's purpose
- Component layout (bin/, src/, conf/, docs/)
- Detailed execution flow (10 steps)
- Configuration model with INI format
- Logging and audit mechanisms
- Date dimension usage
- Robustness and scale considerations
- Mermaid flowchart diagram embedded
- Operational notes and limitations

### 3. Flowchart Source
**File**: `DDS_Framework_Flowchart.mmd`

Mermaid diagram source code for the architecture flowchart showing:
- User invocation via spark3-submit
- Launcher configuration reading
- Validation and logging setup
- Ingestion job execution
- SparkSession creation
- Business date resolution
- Schema discovery
- Target existence check
- CTAS (create) or INSERT (update) paths
- Counting and audit
- Spark shutdown and log copying

**Can be**:
- Edited in any Mermaid-compatible editor
- Rendered in GitHub markdown
- Converted to PNG, SVG, or PDF
- Integrated into other documentation

### 4. Architecture Diagram
**File**: `architecture_diagram.svg`

Professional SVG diagram illustrating:
- User interaction point
- Launcher component with configuration reading
- HDFS configuration storage
- Ingestion job with Spark flame icon
- Date dimension integration
- Data flow paths
- Log file management
- Audit trail recording

**Benefits**:
- Scalable vector graphics (SVG format)
- Can be embedded in web pages or documents
- High-quality rendering at any size
- Editable in vector graphics software

### 5. Presentation Guide
**File**: `PRESENTATION_GUIDE.md`

Comprehensive guide covering:
- Detailed description of each slide
- Content breakdown for all 10 slides
- Additional files explanation
- Usage instructions for viewing and editing
- Technical highlights summary
- Framework design decisions
- Source material reference

## Framework Architecture Highlights

### Components
1. **Launcher** (bin/run_ingestion.py)
   - Python orchestrator without SparkSession
   - Reads HDFS configuration
   - Validates parameters
   - Manages unified logging

2. **Ingestion Job** (src/dds_framework/ingestion_job.py)
   - Creates SparkSession with Hive support
   - Executes SQL-only operations (CTAS/INSERT)
   - Handles dynamic partitioning

3. **Supporting Modules**
   - logging_utils.py - Logging infrastructure
   - audit_capture.py - Audit trail management

### Key Features
- ✅ **Automatic date resolution** from date dimension
- ✅ **Robust concurrency** with CTAS IF NOT EXISTS
- ✅ **Dynamic partitioning** for safe multi-partition writes
- ✅ **Unified logging** (launcher + ingestion in one file)
- ✅ **Comprehensive auditing** to default.dds_ingestion_audit
- ✅ **SQL-only operations** for reliability
- ✅ **HDFS configuration** per user isolation
- ✅ **Scalable design** for CDP/Hive environments

### Execution Flow
```
User → Launcher → Config Validation → Ingestion Job → Date Resolution → 
Schema Discovery → Target Check → [CTAS | INSERT] → Count & Audit → 
Stop Spark → Copy Logs
```

### Configuration Model
- Location: `/user/<os_user>/jobs.config`
- Format: INI with [common] and [jobs.<name>] sections
- Required: VIEW_NAME, TARGET_TABLE, LOAD_METHOD, SRC_SYSTEM, SITE_ID
- Optional: BIZ_DT (auto-resolved), Spark configs, log level

## Source Material
All deliverables are based on **DDS_Framework 5.zip** which contains:
- Complete framework source code (Python)
- Existing documentation and diagrams
- Configuration examples
- Utility scripts (load_date_dim_2025.py, etc.)
- Test harness

## How to Use

### For Presentations
1. Open `DDS_Framework_Architecture_Presentation.pptx` in PowerPoint, Google Slides, or compatible software
2. Present the 10 slides to explain the framework architecture
3. Use the flowcharts and diagrams to illustrate data flow and execution

### For Documentation
1. Review `DDS_Framework_Architecture.md` for complete technical details
2. Reference `PRESENTATION_GUIDE.md` for slide-by-slide breakdown
3. View `architecture_diagram.svg` in any browser or image viewer

### For Editing
1. Edit Mermaid flowchart: `DDS_Framework_Flowchart.mmd`
2. Edit SVG diagram: `architecture_diagram.svg` (use Inkscape, Adobe Illustrator, etc.)
3. Edit PowerPoint: `DDS_Framework_Architecture_Presentation.pptx`

## Technical Specifications

### Presentation Details
- **Format**: Microsoft PowerPoint (.pptx)
- **Slides**: 10
- **Size**: ~39 KB
- **Compatibility**: PowerPoint 2007+, Google Slides, LibreOffice Impress

### Diagram Formats
- **Flowchart**: Mermaid (.mmd) - text-based, version-control friendly
- **Architecture**: SVG (Scalable Vector Graphics) - high quality, scalable

### Documentation
- **Format**: Markdown (.md) - readable, version-control friendly
- **Total**: 3 markdown files with comprehensive coverage

## Conclusion
This deliverable package provides a complete presentation and documentation suite for the DDS Framework based on the DDS_Framework 5.zip contents. The materials include:

✅ Professional PowerPoint presentation with flowcharts  
✅ Complete architecture diagram in SVG format  
✅ Detailed design documentation  
✅ Editable Mermaid flowchart source  
✅ Comprehensive presentation guide  

All materials are production-ready and suitable for:
- Technical presentations
- Architecture reviews
- Documentation repositories
- Training materials
- Stakeholder communications

**Created**: November 1, 2025  
**Based on**: DDS_Framework 5.zip  
**Total Files**: 5 (1 PPTX, 1 SVG, 1 MMD, 3 MD)
