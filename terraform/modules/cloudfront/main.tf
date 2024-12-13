resource "aws_cloudfront_distribution" "spa_and_media" {
  for_each = merge(
    var.spa_buckets,
    { "media" = var.media_bucket }
  )

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200" # Excludes South America and Australia for cost savings
  default_root_object = each.key == "media" ? null : "index.html"

  origin {
    domain_name = each.value.bucket_regional_domain_name
    origin_id   = "S3-${each.key}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main[each.key].cloudfront_access_identity_path
    }

    origin_shield {
      enabled              = true
      origin_shield_region = var.aws_region
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${each.key}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    # Lambda@Edge for video encryption
    dynamic "lambda_function_association" {
      for_each = each.key == "media" ? [1] : []
      content {
        event_type   = "viewer-request"
        lambda_arn   = aws_lambda_function.video_auth.qualified_arn
        include_body = false
      }
    }
  }

  # Custom error response for SPAs
  dynamic "custom_error_response" {
    for_each = each.key != "media" ? [1] : []
    content {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.allowed_countries
    }
  }

  web_acl_id = var.waf_web_acl_id

  tags = var.tags
}

# Lambda@Edge for video encryption
resource "aws_lambda_function" "video_auth" {
  filename      = "${path.module}/functions/video-auth.zip"
  function_name = "${var.environment}-video-auth"
  role          = aws_iam_role.lambda_edge.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  publish       = true

  tags = var.tags
}
