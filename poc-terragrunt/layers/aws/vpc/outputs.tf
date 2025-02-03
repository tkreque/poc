#################
# Output
#################

output "vpc_id" {
  value = aws_vpc.this.id  
}

output "vpc_private_subnet_ids" {
  value = aws_subnet.private.*.id 
}

output "vpc_public_subnet_ids" {
  value = aws_subnet.public.*.id 
}
