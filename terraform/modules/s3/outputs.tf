output "spa_bucket_ids" {
  value = { for k, v in aws_s3_bucket.spa : k => v.id }
}

output "media_bucket_id" {
  value = aws_s3_bucket.media.id
}
