# DDS Framework Architecture Presentation Guide

## Overview
This document serves as a guide to the PowerPoint presentation created from the DDS_Framework 5.zip contents. The presentation provides a comprehensive overview of the DDS (Data Distribution System) PySpark Ingestion Framework with flowcharts, design documentation, and architecture diagrams.

## Presentation Contents

### Slide 1: Title Slide
- **Title**: DDS Framework
- **Subtitle**: PySpark Ingestion Framework - Architecture & Design Documentation
- Professional blue-themed title slide

### Slide 2: Framework Overview
- **Purpose**: Reusable PySpark ingestion framework for data movement
- **Key Features**:
  - Moves data from curated Hive views to managed Hive tables
  - Designed for scale in CDP/Hive environment
  - Robust filtering with dynamic partitioning
  - Comprehensive audit trail and logging
  - Automatic business date resolution
  - SQL-only ingestion (CTAS/INSERT statements)

### Slide 3: Architecture Flowchart
- **Visual flowchart** showing the complete execution path:
  1. User invokes via spark3-submit
  2. Launcher reads HDFS configuration
  3. Configuration validation
  4. Ingestion job with SparkSession
  5. Date dimension lookup (if needed)
  6. Decision point: Target table exists?
  7. Two paths: CTAS (create) or INSERT (update)
  8. Count records and audit trail
  9. Stop Spark and copy logs

### Slide 4: Framework Components
- **Launcher (bin/run_ingestion.py)**:
  - Python launcher without SparkSession
  - Reads HDFS config from /user/<os_user>/jobs.config
  - Validates parameters and manages unified logging

- **Ingestion Job (src/dds_framework/ingestion_job.py)**:
  - Creates SparkSession with Hive support
  - Performs SQL-only CTAS/INSERT operations
  - Handles dynamic partitioning

- **Supporting Modules**:
  - logging_utils.py - Unified logging infrastructure
  - audit_capture.py - SQL-only audit INSERT

### Slide 5: Architecture Design Details
- **Separation of Concerns**:
  - Launcher: Orchestration only (no Spark)
  - Ingestion: All Spark operations

- **Configuration Management**:
  - INI format stored in HDFS per user
  - [common] section for shared defaults
  - [jobs.<name>] sections for job-specific config

- **Data Management**:
  - Managed Hive tables with PARQUET format
  - Dynamic partitioning enabled
  - First-time creation via CTAS IF NOT EXISTS

### Slide 6: Data Flow Architecture
- **Visual data flow diagram** showing:
  - Source Hive View → Filtering (by src_system, site_id, biz_dt) → Target Hive Table
  - Date Dimension interaction for business date resolution
  - Audit table recording execution metadata

### Slide 7: Execution Flow
- **Step-by-step execution process**:
  1. User invokes launcher with job name
  2. Configuration loading and validation
  3. Ingestion execution with SparkSession
  4. Business date resolution
  5. Schema discovery and predicate building
  6. CTAS or INSERT based on target existence
  7. Record counting and audit trail insertion

### Slide 8: Configuration Model
- **Location**: /user/<os_user>/jobs.config

- **Required Job Parameters**:
  - VIEW_NAME - Source Hive view
  - TARGET_TABLE - Destination Hive table
  - LOAD_METHOD - append or overwrite
  - SRC_SYSTEM - Source system identifier (comma-separated)
  - SITE_ID - Site identifier (comma-separated)

- **Optional Parameters**:
  - BIZ_DT - Business date (auto-resolved if omitted)
  - Spark configuration overrides
  - Log level customization

### Slide 9: Key Features & Robustness
- **Automatic Date Resolution**:
  - Resolves latest business date from dds_meta.date_dim
  - Filtered by src_system and site_id for efficiency

- **Robust Concurrency**:
  - CTAS IF NOT EXISTS prevents conflicts
  - Unique log filenames for concurrent runs
  - Dynamic partitions for safe multi-partition writes

- **Comprehensive Auditing & Logging**:
  - Unified log file (launcher + ingestion)
  - Audit table: default.dds_ingestion_audit
  - Captures user, timing, counts, and configurations

### Slide 10: Summary
- **DDS Framework Benefits**:
  - Reusable and scalable PySpark ingestion solution
  - Clear separation of concerns
  - Robust handling of concurrent operations
  - Comprehensive auditing and logging
  - Flexible configuration management

- **Production Ready Features**:
  - SQL-only operations for reliability
  - Dynamic partitioning support
  - Automatic business date resolution
  - Designed for CDP/Hive at scale

## Additional Files Included

### 1. DDS_Framework_Architecture.md
Complete architecture documentation extracted from the framework, including:
- Component layout and descriptions
- Execution flow details
- Configuration model specifications
- Operational notes and limitations

### 2. DDS_Framework_Flowchart.mmd
Mermaid diagram source for the architecture flowchart, which can be:
- Edited in Mermaid-compatible editors
- Rendered in GitHub markdown
- Converted to other diagram formats

### 3. architecture_diagram.svg
Visual architecture diagram showing:
- User interaction flow
- Launcher component
- HDFS configuration storage
- Ingestion job with SparkSession
- Date dimension integration
- Audit and logging mechanisms

## Source Material
All content is based on **DDS_Framework 5.zip**, which contains:
- Complete framework source code
- Documentation and diagrams
- Configuration examples
- Utility scripts

## Usage Instructions

### Viewing the Presentation
1. Open `DDS_Framework_Architecture_Presentation.pptx` in:
   - Microsoft PowerPoint
   - Google Slides
   - LibreOffice Impress
   - Any compatible presentation software

### Editing the Diagrams
1. **Flowchart**: Edit `DDS_Framework_Flowchart.mmd` in Mermaid editors
2. **Architecture Diagram**: The SVG can be edited in vector graphics software

### Understanding the Framework
1. Start with the presentation for a high-level overview
2. Review `DDS_Framework_Architecture.md` for detailed documentation
3. Examine the flowchart and architecture diagram for visual understanding
4. Refer to the original ZIP file for source code and examples

## Technical Highlights

### Framework Architecture
- **Single SparkSession per run**: Ensures resource efficiency
- **SQL-only operations**: CTAS and INSERT statements for reliability
- **Dynamic partitioning**: Safe multi-partition writes
- **Concurrent execution safe**: Unique log filenames and CTAS IF NOT EXISTS

### Data Flow
1. Launcher reads user-specific HDFS configuration
2. Validates required parameters (src_system, site_id, etc.)
3. Ingestion creates SparkSession with Hive support
4. Resolves business date from date dimension if not provided
5. Filters source view by predicates
6. Creates or updates target table
7. Records audit trail with counts and metadata

### Key Design Decisions
- **Separation**: Launcher has no Spark; ingestion has all Spark logic
- **Configuration**: INI format in HDFS per user for isolation
- **Logging**: Unified log file shared by launcher and ingestion
- **Audit**: SQL-only INSERT to audit table for consistency
- **Robustness**: CTAS IF NOT EXISTS, dynamic partitions, unique logs

## Conclusion
This presentation and accompanying documentation provide a complete view of the DDS Framework architecture, design decisions, and operational characteristics. The framework is production-ready, scalable, and designed for enterprise data ingestion workloads in CDP/Hive environments.
