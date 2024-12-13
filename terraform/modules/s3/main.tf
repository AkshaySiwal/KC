# SPA Buckets in Primary Region
resource "aws_s3_bucket" "spa" {
  provider = aws.primary
  for_each = toset(["react", "svelte"])

  bucket = "${var.environment}-${each.key}-spa"
  tags   = var.tags
}

# Media Bucket in Primary Region
resource "aws_s3_bucket" "media" {
  provider = aws.primary
  bucket   = "${var.environment}-media"
  tags     = var.tags
}

# Enable versioning for Primary Region buckets
resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  for_each = merge(
    aws_s3_bucket.spa,
    { "media" = aws_s3_bucket.media }
  )

  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for Primary Region buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  provider = aws.primary
  for_each = merge(
    aws_s3_bucket.spa,
    { "media" = aws_s3_bucket.media }
  )

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DR Region Replica Buckets
resource "aws_s3_bucket" "dr_replica" {
  provider = aws.dr
  for_each = merge(
    aws_s3_bucket.spa,
    { "media" = aws_s3_bucket.media }
  )

  bucket = "${var.environment}-${each.key}-dr-replica"
  tags   = var.tags
}

# Enable versioning for DR Region buckets
resource "aws_s3_bucket_versioning" "dr" {
  provider = aws.dr
  for_each = aws_s3_bucket.dr_replica

  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for DR Region buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "dr" {
  provider = aws.dr
  for_each = aws_s3_bucket.dr_replica

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Role for replication
resource "aws_iam_role" "replication" {
  provider = aws.primary
  name     = "${var.environment}-s3-bucket-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for replication
resource "aws_iam_role_policy" "replication" {
  provider = aws.primary
  name     = "${var.environment}-s3-bucket-replication-policy"
  role     = aws_iam_role.replication.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = concat(
          [for bucket in aws_s3_bucket.spa : bucket.arn],
          [aws_s3_bucket.media.arn]
        )
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = concat(
          [for bucket in aws_s3_bucket.spa : "${bucket.arn}/*"],
          ["${aws_s3_bucket.media.arn}/*"]
        )
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect   = "Allow"
        Resource = [for bucket in aws_s3_bucket.dr_replica : "${bucket.arn}/*"]
      }
    ]
  })
}

# Replication configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.primary
  for_each = merge(
    aws_s3_bucket.spa,
    { "media" = aws_s3_bucket.media }
  )
  depends_on = [
    aws_s3_bucket_versioning.primary,
    aws_s3_bucket_versioning.dr
  ]

  role   = aws_iam_role.replication.arn
  bucket = each.value.id

  rule {
    id     = "ReplicateAll"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.dr_replica[each.key].arn
      storage_class = "STANDARD_IA"
    }
  }
}
