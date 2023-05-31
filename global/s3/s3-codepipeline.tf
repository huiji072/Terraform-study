resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = local.bucket
  acl    = "private"
}

resource "aws_s3_bucket_object" "example_folder" {
  bucket         = aws_s3_bucket.pipeline_bucket.id
  key            = "${local.folder}/"
  content_type   = "application/x-directory"
  force_destroy = true

}

resource "aws_s3_bucket_object" "example_file" {
  depends_on = [aws_s3_bucket_object.example_folder]
  bucket     = aws_s3_bucket.pipeline_bucket.id
  key        = "${local.folder}/${local.file}"
  content_type = "text/plain"
  force_destroy = true

  # source = "./example2.txt"
}