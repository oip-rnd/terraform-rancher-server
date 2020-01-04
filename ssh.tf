resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  sensitive_content = tls_private_key.ssh.private_key_pem
  filename          = "${var.creds_output_path}/id_rsa"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.creds_output_path}/id_rsa"
  }
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "${var.creds_output_path}/id_rsa.pub"
}

resource "aws_key_pair" "ssh" {
  key_name_prefix = local.name
  public_key      = tls_private_key.ssh.public_key_openssh
}

resource "aws_ssm_parameter" "private_rsa_key" {
  name        = "/${local.name}/id_rsa"
  type        = "SecureString"
  value       = tls_private_key.ssh.private_key_pem
}

resource "aws_ssm_parameter" "public_rsa_key" {
  name        = "/${local.name}/id_rsa.pub"
  type        = "SecureString"
  value       = tls_private_key.ssh.private_key_pem
}
