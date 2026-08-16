output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "sonarqube_ip" {
  value = aws_instance.sonarqube.public_ip
}

output "sonarqube_url" {
  value = "http://${aws_instance.sonarqube.public_ip}:9000"
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}
