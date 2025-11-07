terraform {
  backend "s3" {
    bucket         = "hiagogouveia-eks-tfstate-actual-sailfish" 
    key            = "eks-prometheus-lab/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" 
    encrypt        = true
  }
}