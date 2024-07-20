resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

locals {
  s3_origin_id   = "${aws_s3_bucket.bucket.id}-origin"
  s3_domain_name = "${aws_s3_bucket.bucket.bucket_regional_domain_name}"
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "originAccessControlGenerateValuesDev"
  description                       = "Policy permission s3 cloudfront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = local.s3_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "OPTIONS", "HEAD"]
    cached_methods   = ["GET", "OPTIONS", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_200"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<POLICY
{
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
                "Condition": {
                    "StringEquals": {
                      "AWS:SourceArn": "arn:aws:cloudfront::709894680066:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
                    }
                }
            }
        ]
      }
POLICY
}