variable "config" {
  type = list(object({
    eks = object({
      region                      = optional(string, "us-east-1")
      cluster_name                = string
      node_group_name             = string
      scaling_config_desired_size = optional(number, 5)
      scalling_cluster_max        = optional(number, 5)
      scalling_cluster_min        = optional(number, 5)
      instance_types              = optional(string, "t3.medium")
    })
    crtm = object({
      cert_manager_crd = string
      cert_manager_name = optional(string, "cert-manager")
      cert_manager_repository = string
      cert_manager_version = string
      cert_manager_chart = string
      cert_manager_namespace = optional(string, "cert-manager")
      cert_manager_create_namespace = optional(bool, true)
      cert_manager_letsencrypt = string
    })
    nginx = object({
      nginx_name = optional(string, "nginx")
      nginx_repository = string
      nginx_version = string
      nginx_chart = string
      nginx_create_namespace = optional(bool, true)
      nginx_namespace = optional(string, "nginx")
    })
    ebs = object({
      ebs_name = optional(string, "aws-ebs-csi-driver")
      ebs_repository = string
      ebs_chart = string
      ebs_version = string
      ebs_namespace = optional(string, "kube-system") 
      ebs_sc_default_file = optional(string, "sc.yaml")
      ebs_pvc_default_file = optional(string, "pvc.yaml")
    })
  }))
}
