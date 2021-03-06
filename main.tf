provider "kubernetes" {
  config_path = var.kubeconfig_filename
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_filename
  }
}

module "eks-base" {
  source               = "github.com/uktrade/terraform-module-eks-base//base"
  cluster_name         = var.cluster_name
  cluster_id           = var.cluster_id
  worker_iam_role_name = var.worker_iam_role_name
  kubeconfig_filename  = var.kubeconfig_filename
  helm_release         = var.helm_release
  eks_config           = var.eks_config
  eks_extra_config     = var.eks_extra_config
}

module "eks-dashboard" {
  source                 = "github.com/uktrade/terraform-module-eks-base//dashboard"
  cluster_name           = var.cluster_name
  cluster_id             = var.cluster_id
  cluster_ca_certificate = var.cluster_ca_certificate
  kubeconfig_filename    = var.kubeconfig_filename
  dashboard_oauth_config = var.dashboard_oauth_config
  helm_release           = var.helm_release
  eks_extra_config       = var.eks_extra_config
}

module "eks-registry" {
  source              = "github.com/uktrade/terraform-module-eks-base//docker-registry"
  cluster_name        = var.cluster_name
  cluster_id          = var.cluster_id
  kubeconfig_filename = var.kubeconfig_filename
  registry_config     = var.registry_config
  helm_release        = var.helm_release
  eks_extra_config    = var.eks_extra_config
}

module "eks-metrics" {
  source              = "github.com/uktrade/terraform-module-eks-base//metrics"
  cluster_name        = var.cluster_name
  cluster_id          = var.cluster_id
  kubeconfig_filename = var.kubeconfig_filename
  metric_config       = var.metric_config
  helm_release        = var.helm_release
  eks_extra_config    = var.eks_extra_config
}

module "eks-logging" {
  source              = "github.com/uktrade/terraform-module-eks-base//logging"
  cluster_name        = var.cluster_name
  cluster_id          = var.cluster_id
  kubeconfig_filename = var.kubeconfig_filename
  logging_config      = var.logging_config
  helm_release        = var.helm_release
  eks_extra_config    = var.eks_extra_config
}
