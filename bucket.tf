resource "aws_s3_bucket" "models" {
  bucket_prefix = "dog-breed-model-"
}

resource "aws_s3_bucket_object" "model" {
  bucket = aws_s3_bucket.models.id
  key    = "model.tar.gz"
  source = "model.tar.gz"
  etag   = filemd5("model.tar.gz")
}
