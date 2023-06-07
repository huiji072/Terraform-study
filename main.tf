module "vpc" {
  source = "./vpc"
}

module "service-ec2-test-app" {
  source              = "./service/ec2/test-app"
  github_token        = var.github_token
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  s3_codepipeline_id  = module.global.s3_codepipeline_id
  s3_codepipeline_arn = "arn:aws:s3:::${module.global.s3_codepipeline_id}"
}

module "service-ecs-test-app" {
  source              = "./service/ecs/test-app"
  github_token        = var.github_token
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  s3_codepipeline_id  = module.global.s3_codepipeline_id
  s3_codepipeline_arn = "arn:aws:s3:::${module.global.s3_codepipeline_id}"
}

module "global" {
  source = "./global/s3"
}

