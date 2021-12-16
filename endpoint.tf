resource "aws_sagemaker_endpoint_configuration" "main" {
  name = "dog-breed-endpoint"

  production_variants {
    variant_name           = "main"
    model_name             = "pytorch-training-2021-12-15-00-43-56-977"
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = "dog-breed-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name
}
