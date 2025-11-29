# Mock Exam #2 – Log Pipeline, Storage, CI

## Scenario

You are building a small log processing pipeline.

### Tasks

1. **Log Processor (Python or Bash)**
   - Read `access.log` from the current directory.
   - Count requests per HTTP status code.
   - Output JSON mapping of `status_code -> count`.

2. **Terraform (Storage)**
   - Create a storage bucket for processed logs.
   - Use variables for:
     - bucket name
     - environment
   - Enable versioning and server-side encryption.

3. **CI Pipeline (YAML)**
   - Create a CI pipeline config (`ci-pipeline.yaml`) that:
     - Runs tests (if any).
     - Packages the log processor as a Docker image.
     - Pushes the image to a container registry (use placeholder).
   - Hint: GitHub Actions style is fine.

4. **Bonus**
   - Add a shell script to upload processed JSON output to the bucket
     (assume `aws s3 cp` or similar is available).

Soft timebox: 60 minutes.
