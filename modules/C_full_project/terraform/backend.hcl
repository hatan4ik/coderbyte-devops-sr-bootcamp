bucket         = "terraform-state-bucket"
key            = "devops-demo/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"
