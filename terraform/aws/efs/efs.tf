
# Create an Elastic File System (EFS)
resource "aws_efs_file_system" "raogaru-efs" {
  creation_token = "raogaru-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true
}

# Create a mount target in a specific subnet
resource "aws_efs_mount_target" "raogaru-efs" {
  file_system_id = aws_efs_file_system.raogaru-efs.id
  subnet_id = "subnet-12345678" 
  security_groups = [aws_security_group.example.id] # Replace with the security group ID
}

# Define a security group to control access to the EFS
resource "aws_security_group" "aws-efs-sg" {
  name        = "aws-efs-sg"
  description = "security group for EFS mount"
  
  # Add rules to allow traffic from your instances
  # For example, to allow traffic from instances in the same VPC:
  # Ingress rule for NFS (port 2049)
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }
}

# Output the DNS name of the EFS filesystem
output "efs_dns_name" {
  value = aws_efs_file_system.raogaru-efs.dns_name
}

