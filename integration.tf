variable "region" {
  default = "us-east-1"
}

data "aws_iam_policy_document" "apigw_sm_invoke_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apigw_sm_invoke" {
  name               = "dog-breed-sm-invoke"
  assume_role_policy = data.aws_iam_policy_document.apigw_sm_invoke_assume_role.json
}


data "aws_iam_policy_document" "apigw_sm_invoke_access" {
  statement {
    actions   = ["sagemaker:InvokeEndpoint"]
    resources = [aws_sagemaker_endpoint.endpoint.arn]
  }
}

resource "aws_iam_role_policy" "apigw_sagemaker_invoke" {
  role   = aws_iam_role.apigw_sm_invoke.name
  policy = data.aws_iam_policy_document.apigw_sm_invoke_access.json
}

resource "aws_api_gateway_integration" "predict" {
  depends_on = [aws_iam_role_policy.apigw_sagemaker_invoke]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id

  type                    = "AWS"
  http_method             = aws_api_gateway_method.predict.http_method
  integration_http_method = "POST"

  credentials = aws_iam_role.apigw_sm_invoke.arn
  uri         = "arn:aws:apigateway:${var.region}:runtime.sagemaker:path//endpoints/${aws_sagemaker_endpoint.endpoint.name}/invocations"
}

resource "aws_api_gateway_integration_response" "predict" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_integration.predict.http_method
  status_code = aws_api_gateway_method_response.predict_200.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "predict" {
  depends_on = [aws_api_gateway_integration_response.predict]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "predict"
  description = "Dob Breed Inference API"
}

output "invoke_url" {
  value = aws_api_gateway_deployment.predict.invoke_url
}
