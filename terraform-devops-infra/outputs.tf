output "jenkins_ip" {
  value = try(aws_instance.jenkins[0].public_ip, "Jenkins server not created")
}

output "jenkins_url" {
  value = try("http://${aws_instance.jenkins[0].public_ip}:8080", "Jenkins server not created")
}

output "sonarqube_ip" {
  value = try(aws_instance.sonarqube[0].public_ip, "SonarQube server not created")
}

output "sonarqube_url" {
  value = try("http://${aws_instance.sonarqube[0].public_ip}:9000", "SonarQube server not created")
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}
