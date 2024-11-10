
# Create an Elastic File System (EFS)
resource "aws_efs_file_system" "raogaru-efs" {
  creation_token = "raogaru-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true
  tags = { Name = "raogaru-efs" }

}

# Create a mount target in a specific subnet
resource "aws_efs_mount_target" "raogaru-efs" {
  file_system_id = aws_efs_file_system.raogaru-efs.id
  #subnet_id = data.aws_subnet.default.id 
  subnet_id = "subnet-06acb79fcb1a60a5e"
  security_groups = [aws_default_security_group.default.id]
}

# Output the DNS name of the EFS filesystem
output "efs_dns_name" {
  value = aws_efs_file_system.raogaru-efs.dns_name
}

