variable "region" {
  default = "us-east-1"
}

data "aws_iam_policy_document" "sm_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sm_execution" {
  name               = "dog-breed-sm-execution"
  assume_role_policy = data.aws_iam_policy_document.sm_assume_role.json
}

resource "aws_iam_role_policy_attachment" "sm_execution" {
  role       = aws_iam_role.sm_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

data "aws_iam_policy_document" "sm_access" {
  statement {
    actions   = ["s3:ListBucket", "s3:GetObject*"]
    resources = [aws_s3_bucket.models.arn, "${aws_s3_bucket.models.arn}/*"]
  }
}

resource "aws_iam_role_policy" "sm_access" {
  role   = aws_iam_role.sm_execution.name
  policy = data.aws_iam_policy_document.sm_access.json
}

resource "aws_sagemaker_model" "model" {
  name               = "dog-breed-model"
  execution_role_arn = aws_iam_role.sm_execution.arn

  primary_container {
    image          = "763104351884.dkr.ecr.${var.region}.amazonaws.com/pytorch-inference:1.9.0-gpu-py38"
    model_data_url = "s3://${aws_s3_bucket.models.id}/${aws_s3_bucket_object.model.key}"

    environment = {
      SAGEMAKER_CONTAINER_LOG_LEVEL = "20"
      SAGEMAKER_PROGRAM             = "entrypoint.py"
      SAGEMAKER_REGION              = "${var.region}"
      SAGEMAKER_SUBMIT_DIRECTORY    = "s3://${aws_s3_bucket.models.id}/${aws_s3_bucket_object.model.key}"
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "main" {
  name = "dog-breed-endpoint"

  production_variants {
    variant_name           = "main"
    model_name             = aws_sagemaker_model.model.name
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = "dog-breed-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name
}
