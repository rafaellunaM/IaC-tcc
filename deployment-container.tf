#   provisioner "local-exec" {
#     command = "kubectl create configmap aws-env --from-env-file=aws.env"
#   }
#   depends_on = [ helm_release.cert-manager ]
# }

# resource "kubectl_manifest" "configmap_aws_env" {
#   yaml_body = <<YAML
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-env
#   namespace: default
# data:
#   aws.env: |
# ${indent(4, file("${path.module}/aws.env"))}
# YAML
# }


     
# resource "null_resource" "configmap_install_tools" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/deployments/install-tools.yaml"
#   }
#   depends_on = [ kubectl_manifest.configmap_aws_env ]
# }

# resource "null_resource" "configmap_install_hlf" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/deployments/install-hlf.yaml"
#   }
#   depends_on = [ null_resource.configmap_install_tools ]
# }

# resource "null_resource" "install_toolbox" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ${path.module}/deployments/toolbox.yaml"
#   }
#   depends_on = [ null_resource.configmap_install_tools ]
# }

# resource "null_resource" "clusterrolebinding" {
#   provisioner "local-exec" {
#     command = "kubectl create clusterrolebinding default-admin --clusterrole=cluster-admin --serviceaccount=default:default"
#   }
#   depends_on = [ null_resource.install_toolbox ]
# }
