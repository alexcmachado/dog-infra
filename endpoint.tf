resource "aws_sagemaker_endpoint_configuration" "main" {
  name = "dog-breed-endpoint"

  production_variants {
    variant_name           = "main"
    model_name             = "pytorch-transfer-2021-12-23-20-48-07-581"
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = "dog-breed-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name
}
