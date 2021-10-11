# Local Provisioner - Runs on your local Macbook Pro/Linux instance to
# 1. Configure the local ~/.kube/config file for accessing the AKS cluster

resource "local_file" "eks-kubeconfig" {
  content    = module.eks.kubeconfig
  filename   = "${path.module}/eks-kubeconfig"
  depends_on = [module.eks.kubeconfig]
}


resource "null_resource" "local_mac_provisioner" {
  provisioner "local-exec" {
    command = <<EOT
        echo ""
        echo "################################################################################"
        echo "# Running local provisioner to set KUBECONFIG"
        echo "################################################################################"
        echo ""
        aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
        EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
    rm ./eks-kubeconfig
    EOT
  }

  depends_on = [module.eks.cluster, local_file.eks-kubeconfig]
}