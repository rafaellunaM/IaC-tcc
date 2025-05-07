resource "null_resource" "configmap_aws_env" {
  provisioner "local-exec" {
    command = "kubectl create configmap aws-env --from-env-file=aws.env"
  }
  depends_on = [ helm_release.cert-manager ]
}

resource "null_resource" "configmap_install_tools" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deployments/install-tools.yaml"
  }
  depends_on = [ null_resource.configmap_aws_env ]
}

resource "null_resource" "configmap_install_hlf" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deployments/install-hlf.yaml"
  }
  depends_on = [ null_resource.configmap_install_tools ]
}

resource "null_resource" "install_toolbox" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deployments/toolbox.yaml"
  }
  depends_on = [ null_resource.configmap_install_tools ]
}

resource "null_resource" "clusterrolebinding" {
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding default-admin --clusterrole=cluster-admin --serviceaccount=default:default"
  }
  depends_on = [ null_resource.install_toolbox ]
}
