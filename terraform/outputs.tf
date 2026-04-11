output "ecr_repo_url" {
  value = module.infra.ecr_repo_url
}

output "lambda_name" {
   value = length(module.lambda) > 0 ? module.lambda[0].lambda_name : null
}
