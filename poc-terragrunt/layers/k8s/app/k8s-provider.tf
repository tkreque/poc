provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# data "aws_eks_cluster" "default" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster_auth" "default" {
#   name = var.cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.default.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.default.token
# }
