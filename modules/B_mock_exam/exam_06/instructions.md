# Mock Exam #6 – Cloud Networking & Peering

## Scenario
Build two isolated VPCs and connect them with peering. Demonstrate connectivity with a simple instance or stub.

## Requirements
1. **Terraform** (in `starter/terraform`)
   - Create VPC A and VPC B with configurable CIDRs.
   - Add one public subnet in each VPC, internet gateway, and route tables.
   - Create a VPC peering connection between the two VPCs.
   - Add routes so VPC A and VPC B can reach each other.
   - Security groups should allow ICMP/SSH only from provided CIDRs (no 0.0.0.0/0).
2. **Validation**
   - Output subnet IDs, peering ID, and route table IDs.
   - Add a small `README` describing how you would test connectivity (e.g., ping between EC2 instances or VPC Reachability Analyzer).
3. **Extras (optional)**
   - Add flow logs to S3/CloudWatch.
   - Use Terraform modules/locals for reuse.

### Deliverables
- Terraform configuration under `starter/terraform` implementing the above.
- README with testing steps and any assumptions.
