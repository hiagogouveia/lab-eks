# --- 1. REDE (VPC) ---
# Usa a versão estável 5.1.2 do módulo VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "lab"
  }
}

# --- 2. CLUSTER EKS ---
# Usa a versão estável 20.8.4 do módulo EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT" # Mais barato para o lab
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "lab"
  }
}

# --- 2.1. PERMISSÃO ADMIN NO CLUSTER (O NOVO JEITO) ---
# (Este é o bloco que você adicionou manualmente no console,
# agora escrito em código Terraform)

resource "aws_eks_access_entry" "admin_access" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::083523845001:user/hiagogouveia"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_policy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.admin_access.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin_access]
}

# --- 3. PAPEL IAM PARA O GRAFANA (IRSA) ---
# (Este código já estava correto)

data "aws_iam_openid_connect_provider" "eks_oidc" {
  # Adicionamos o depends_on para evitar a "condição de corrida"
  depends_on = [module.eks]
  url        = "https://${module.eks.oidc_provider}"
}

resource "random_string" "role_suffix" {
  length  = 8
  special = false
  upper   = false
}

data "aws_iam_policy_document" "grafana_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks_oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.eks_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.monitoring_namespace}:${var.grafana_service_account_name}"]
    }
  }
}

resource "aws_iam_role" "grafana_role" {
  name               = "grafana-cloudwatch-reader-${random_string.role_suffix.id}"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume_role.json
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}