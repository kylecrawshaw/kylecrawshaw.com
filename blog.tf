provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_s3_bucket" "www" {
    bucket = "${var.root_domain_name}"
    acl = "public-read"
    policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Sid":"AddPerm",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::kylecrawshaw.com/*"]
        }
    ]
}
POLICY

    website {
        index_document = "index.html"
    }

}

resource "aws_acm_certificate" "certificate" {
  // We want a wildcard cert so we can host subdomains later.
  domain_name       = "*.${var.root_domain_name}"
  validation_method = "EMAIL"

  // We also want the cert to be valid for the root domain even though we'll be
  // redirecting to the www. domain immediately.
  subject_alternative_names = ["${var.root_domain_name}"]
}

resource "aws_cloudfront_distribution" "www_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    
    domain_name = "${aws_s3_bucket.www.website_endpoint}"

    origin_id = "${var.root_domain_name}"
  }

  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    // This needs to match the `origin_id` above.
    target_origin_id       = "${var.root_domain_name}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  aliases = ["${var.root_domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Here's where our certificate is loaded in!
  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    ssl_support_method  = "sni-only"
  }
}

#resource "aws_cloudfront_distribution" "s3_distribution" {
#  origin {
#    domain_name = "${var.bucket_name}.s3.amazonaws.com"
#    origin_id   = "S3-${var.bucket_name}"
#    s3_origin_config {}
#  }
#
#  enabled             = true
#  comment             = "Some comment"
#  default_root_object = "index.html"
#
#  aliases = ["www.kylecrawshaw.com", "kylecrawshaw.com"]
#
#  default_cache_behavior {
#    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#    cached_methods   = ["GET", "HEAD"]
#    target_origin_id = "S3-${var.bucket_name}"
#
#    forwarded_values {
#      query_string = false
#
#      cookies {
#        forward = "none"
#      }
#    }
#
#    viewer_protocol_policy = "allow-all"
#    min_ttl                = 0
#    default_ttl            = 3600
#    max_ttl                = 86400
#  }
#
#  restrictions {
#    geo_restriction {
#      restriction_type = "none"
#    }
#  }
#
#  viewer_certificate {
#    cloudfront_default_certificate = true
#  }
#}
