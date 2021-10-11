# Reference:  https://learn.hashicorp.com/tutorials/terraform/helm-provider?in=terraform/kubernetes

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

resource "kubernetes_namespace" "s1" {
  metadata {
    name = var.s1_namespace
  }
  depends_on = [data.aws_eks_cluster.cluster]
}

locals {
  dockerconfigjson = {
    "auths" = {
      (var.docker_server) = {
        username = var.docker_username
        password = var.docker_password
        auth     = base64encode(join(":", [var.docker_username, var.docker_password]))
      }
    }
  }
}

resource "kubernetes_secret" "s1" {
  metadata {
    name      = var.s1_repository_pull_secret_name
    namespace = var.s1_namespace
  }
  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfigjson)
  }
  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.s1, data.aws_eks_cluster.cluster]
}

resource "helm_release" "sentinelone" {
  name       = var.helm_release_name
  repository = "https://charts.sentinelone.com"
  chart      = "s1-agent"
  namespace  = kubernetes_namespace.s1.metadata[0].name
  set {
    name  = "secrets.imagePullSecret"
    value = var.s1_repository_pull_secret_name
  }
  set {
    name  = "configuration.repositories.helper"
    value = var.s1_helper_image_repository
  }
  set {
    name  = "configuration.tag.helper"
    value = var.s1_helper_image_tag
  }
  set {
    name  = "configuration.cluster.name"
    value = var.cluster_name
  }
  set {
    name  = "configuration.repositories.agent"
    value = var.s1_agent_image_repository
  }
  set {
    name  = "configuration.tag.agent"
    value = var.s1_agent_image_tag
  }
  set {
    name  = "secrets.site_key.value"
    value = var.s1_site_key
  }
  set {
    name  = "helper.nodeSelector\\.kubernetes.io/os'"
    value = "linux"
  }
  set {
    name  = "agent.nodeSelector\\.kubernetes.io/os'"
    value = "linux"
  }

  depends_on = [kubernetes_namespace.s1, kubernetes_secret.s1]
}

