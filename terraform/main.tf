provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "helm_release" "ml_api" {
  name             = "ml-api-${var.environment}"
  chart            = "../charts/ml-api"
  namespace        = "ml-${var.environment}"
  create_namespace = true

  values = [
    file("../charts/ml-api/values-${var.environment}.yaml")
  ]
}

variable "environment" {
  type    = string
  default = "dev"
}