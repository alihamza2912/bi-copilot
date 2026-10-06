import subprocess
import sys
import time
import logging
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
log = logging.getLogger("pipeline")

STAGES = [
    ("extract", ["pipelines/extract.py"]),
    ("load_raw", ["pipelines/load_raw.py"]),
    ("staging", ["pipelines/run_sql.py", "warehouse/01_staging.sql"]),
    ("analytics", ["pipelines/run_sql.py", "warehouse/02_analytics.sql"]),
    ("quality_checks", ["pipelines/run_sql.py", "warehouse/03_dq_checks.sql"]),
]


def main():
    start = time.time()
    for name, args in STAGES:
        t0 = time.time()
        log.info("START %s", name)
        result = subprocess.run([sys.executable, *args], cwd=ROOT)
        secs = time.time() - t0
        if result.returncode != 0:
            log.error("FAILED %s after %.1fs (exit code %s)", name, secs, result.returncode)
            sys.exit(result.returncode)
        log.info("DONE %s in %.1fs", name, secs)
    log.info("PIPELINE COMPLETE in %.1fs", time.time() - start)


if __name__ == "__main__":
    main()