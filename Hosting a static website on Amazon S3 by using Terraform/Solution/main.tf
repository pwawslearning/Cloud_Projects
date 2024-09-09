resource "aws_s3_bucket" "pw-programmatic" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}
resource "aws_s3_bucket_ownership_controls" "pw-programmatic" {
  bucket = aws_s3_bucket.pw-programmatic.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pw-programmatic" {
  bucket = aws_s3_bucket.pw-programmatic.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "versioning_pw-programmatic" {
  bucket = aws_s3_bucket.pw-programmatic.id
  versioning_configuration {
    status = var.status
  }
}

resource "aws_s3_object" "home-page" {
  bucket       = aws_s3_bucket.pw-programmatic.bucket
  key          = "index.html"
  source       = var.source_homepage
  content_type = "text/html"
}

resource "aws_s3_object" "error-page" {
  bucket       = aws_s3_bucket.pw-programmatic.bucket
  key          = "error.html"
  source       = var.source_errorpage
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "redirect-page" {
  bucket = aws_s3_bucket.pw-programmatic.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "error/"
    }
    redirect {
      replace_key_prefix_with = "error.html"
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_public" {
  bucket = aws_s3_bucket.pw-programmatic.id
  policy = data.aws_iam_policy_document.allow_access_from_public.json
}

data "aws_iam_policy_document" "allow_access_from_public" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.pw-programmatic.arn}/*",
    ]
  }
}