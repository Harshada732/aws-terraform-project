output "public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "bucket_name" {
  value = aws_s3_bucket.project_bucket.bucket
}