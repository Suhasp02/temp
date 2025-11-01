# DDS PySpark Ingestion Framework

## Overview
Reusable PySpark ingestion that moves data from curated Hive views to managed Hive tables with robust filtering, dynamic partitioning, audit, and clear logging, designed to run at scale in CDP/Hive.

Key characteristics:
- Single Spark application per run (SparkSession is created only inside the ingestion job).
- One unified log file per run (launcher + ingestion both write to the same file).
- Config read from HDFS under the submitting user’s home: `/user/<os_user>/jobs.config`.
- Mandatory identifiers: `SRC_SYSTEM`, `SITE_ID` (comma-separated supported). `BIZ_DT` is optional.
- If `BIZ_DT` is omitted, the latest date is resolved from a small date dimension: `dds_meta.date_dim`.
- Dynamic partitions enabled; first-time target creation via CTAS IF NOT EXISTS.
- SQL-only ingestion (CTAS/INSERT statements); audit recorded via SQL INSERT.

## Components and layout
```
bin/
  run_ingestion.py        # Launcher (no SparkSession): reads user HDFS config, validates, logs, calls ingestion.run()
  load_date_dim_2025.py   # Offline utility to populate date dimension with 2025 sample data
conf/
  jobs.config             # INI in HDFS /user/<os_user>/jobs.config (launcher reads via hdfs dfs -cat)
docs/
  architecture.md
  architecture.mmd        # Mermaid diagram source
  date_dim_external_table.sql
src/
  dds_framework/
    __init__.py
    logging_utils.py
    audit_capture.py      # SQL-only audit INSERT
    ingestion_job.py      # Main ingestion (builds SparkSession)
```

## Execution flow (high-level)
1. User runs: `spark3-submit bin/run_ingestion.py --job-name <name>`
2. Launcher reads `/user/<os_user>/jobs.config` via the HDFS CLI and merges [common] + [jobs.<name>] settings.
3. Launcher validates required keys, rejects invalid `BIZ_DT` values (`*` or `ALL`), opens a unified log file, builds argv, and calls `dds_framework.ingestion_job.run(argv)`.
4. Ingestion creates a SparkSession with Hive support, resolves submitting user from Spark, and logs parameters.
5. `biz_dt` resolution:
   - If provided, use it as-is.
   - Else: `SELECT MAX(biz_dt) FROM dds_meta.date_dim WHERE src_system IN (...) AND site_id IN (...)`.
6. Build predicates: enforce `src_system`, `site_id`, and `biz_dt` on the view.
7. If target does not exist: CTAS with `IF NOT EXISTS` using `USING PARQUET` (managed table; no LOCATION clause).
8. Else for existing targets: INSERT INTO/OVERWRITE with dynamic partitions.
9. Count inputs/outputs via SQL, audit via SQL INSERT, stop Spark.
10. Launcher copies the unified log file to `/user/<os_user>/logs/<job_name>/`.

## Configuration model
- The INI is stored in HDFS under the submitting user: `/user/<os_user>/jobs.config` (one file per user)
- Sections:
  - `[common]` default scalars and Spark settings (`spark_conf.*`, `submit_conf.*`, optional `spark_options.*`).
  - `[jobs.<name>]` required: `VIEW_NAME`, `TARGET_TABLE`, `LOAD_METHOD`, `SRC_SYSTEM`, `SITE_ID`; optional: `BIZ_DT`, logging level and Spark resource overrides.
- Launcher exposes only `--job-name`. All other values come from the INI.

## Logging
- Unified local file: `logs/<job_name>_<timestamp>_<pid>.log` (launcher and ingestion append).
- Copied on completion to: `/user/<os_user>/logs/<job_name>/`.
- Structured messages at INFO, with context fields: job, user, target, counts, predicates, choices.

## Date dimension (dds_meta.date_dim)
- Purpose: fast `MAX(biz_dt)` lookup to avoid scanning large views.
- Partitioned by `(src_system, site_id)` for pruning; `biz_dt` stored as string `yyyy-MM-dd` (can be DATE if preferred).
- Populated daily by ops (see `docs/date_dim_external_table.sql` and `bin/load_date_dim_2025.py`).

## Audit
- Table: `default.dds_ingestion_audit` (created if missing).
- Insert path: SQL-only `INSERT INTO ... SELECT ...` with `biz_dt = date_format(current_date(), 'yyyy-MM-dd')`.
- Captures: user, job, start/end, duration, view, target, read/loaded counts, configs JSON.

## Robustness and scale
- Single SparkSession per run; launcher has no Spark.
- CTAS uses `IF NOT EXISTS` to withstand concurrent first loads.
- Dynamic partitioning enabled for safe multi-partition writes.
- Stateless operation with unique log filenames makes concurrent runs safe.

## Mermaid diagram
The same diagram is saved as `docs/architecture.mmd` for standalone editing.

```mermaid
flowchart TD
  A[User\n spark3-submit bin/run_ingestion.py --job-name X] --> B[Launcher\nRead /user/<os_user>/jobs.config]
  B --> C[Validate required keys\n BIZ_DT not '*' or 'ALL'\n Open unified log\n Build argv]
  C --> D[Import dds_framework.ingestion_job\nCall run(argv)]
  D --> E[Ingestion\nBuild SparkSession (Hive)]
  E --> F[Resolve user from Spark\nLog params]
  E --> G[Resolve biz_dt\nIf blank: MAX from dds_meta.date_dim filtered by system/site]
  G --> H[Discover schema via DESCRIBE\nChoose partitions\nBuild WHERE]
  H --> I{Target exists?}
  I -- No --> J[CTAS IF NOT EXISTS\nUSING PARQUET\nSELECT ... WHERE ...]
  I -- Yes --> K[INSERT INTO/OVERWRITE\nDynamic partitions]
  J --> L
  K --> L
  L[Count source/loaded (SQL)\nAudit INSERT (SQL)] --> M[Stop Spark]
  M --> N[Launcher copies unified log to /user/<os_user>/logs/<job_name>/]
```

## Operational notes
- Adaptive execution can be enabled via `spark_conf` defaults (`spark.sql.adaptive.enabled=true`).
- Consider partition stats collection for very large overwrites to improve downstream planning.

## Limitations
- Assumes view contains `src_system`, `site_id`, and `biz_dt` columns for filtering and partitioning.
- Audit currently partitions by current processing date; can be switched to the run’s business date if desired.