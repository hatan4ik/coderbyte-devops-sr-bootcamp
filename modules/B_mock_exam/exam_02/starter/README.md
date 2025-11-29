# Log Pipeline Starter

- `log_processor.py`: counts requests per HTTP status code from `access.log` (pass `-` to read STDIN).
- `tests.py`: lightweight sanity test for the processor.
- `Dockerfile`: builds a non-root container; override the log path via `CMD` or args.
- `ci-pipeline.yaml`: GitHub Actions workflow to run tests and build/push the image.
- `upload_processed.sh`: helper to upload JSON output to S3 (`BUCKET` env required).

Quick use:
```bash
python log_processor.py access.log > processed.json
BUCKET=my-bucket ./upload_processed.sh processed.json
```
