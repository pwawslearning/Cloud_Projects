resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh.private_key_openssh
  filename = "${path.root}/ssh_key/private-ssh_key.pem"

  provisioner "local-exec" {
    command = "chmod 400 ${path.root}/ssh_key/private-ssh_key.pem"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project}-${var.environment}-key_pair"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_instance" "this" {
  for_each      = var.instances
  ami           = each.value.ami
  instance_type = each.value.instance_type

  subnet_id = local.subnet_ids[each.value.subnet][0]

  vpc_security_group_ids = [
    var.security_group_ids[each.value.security_group]
  ]
  key_name = (
    each.value.key_name != null
    ? each.value.key_name
    : aws_key_pair.key_pair.key_name
  )
  iam_instance_profile        = each.value.iam_instance_profile
  associate_public_ip_address = each.value.associate_public_ip
  user_data                   = each.value.user_data
  user_data_base64            = each.value.user_data_base64
  disable_api_termination     = each.value.disable_api_termination
  monitoring                  = each.value.monitoring

  root_block_device {
    volume_type           = each.value.root_block_device.volume_type
    volume_size           = each.value.root_block_device.volume_size
    delete_on_termination = each.value.root_block_device.delete_on_termination
    encrypted             = each.value.root_block_device.encrypted
    kms_key_id            = each.value.root_block_device.kms_key_id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ebs_volume" "this" {
  for_each = local.ebs_flat

  availability_zone = aws_instance.this[each.value.instance_key].availability_zone
  type              = each.value.volume_type
  size              = each.value.volume_size
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id

}

resource "aws_volume_attachment" "this" {
  for_each = local.ebs_flat

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.instance_key].id
}