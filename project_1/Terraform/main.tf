resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
}
resource "aws_s3_bucket_ownership_controls" "object_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.status
  }
}

resource "aws_s3_object" "home-page" {
  bucket       = aws_s3_bucket.s3_bucket.bucket
  key          = "index.html"
  source = "${path.module}/html files/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error-page" {
  bucket       = aws_s3_bucket.s3_bucket.bucket
  key          = "error.html"
  source       = "${path.module}/html files/error.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "redirect-page" {
  bucket = aws_s3_bucket.s3_bucket.id

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
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]
  }
}
resource "aws_s3_bucket_policy" "allow_access_from_public" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_public.json
}