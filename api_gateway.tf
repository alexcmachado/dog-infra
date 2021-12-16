resource "aws_api_gateway_rest_api" "api" {
  name = "dog-breed-api"
}

resource "aws_api_gateway_method" "predict" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "predict_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.predict.http_method
  status_code = "200"
}
