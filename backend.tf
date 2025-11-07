terraform {
  # Configura o estado para ser salvo no S3 Bucket e usar a tabela para lock
  backend "s3" {
    bucket         = "hiagogouveia-eks-tfstate-actual-sailfish" 
    key            = "eks-prometheus-lab/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" 
    encrypt        = true
  }
}