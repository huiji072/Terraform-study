output "s3_codepipeline_id" {
  value = aws_s3_bucket.pipeline_bucket.id
  description = "The IDs of the s3 codepipeline"
}
