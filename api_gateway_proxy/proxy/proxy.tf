variable "region" {}
variable "lambda_function_name" {}
variable "gateway_lambda_execution_role_arn" {}
variable "account_id" {}
variable "stage"{}
variable "parent_id" {}
variable "api_id" {}
variable "path" {
  default = "{proxy+}"
}

variable "api_methods" {
  type = "list"
  default = ["GET"]
} #eg ['POST', 'GET']
variable "response_codes" {
  type = "list"
  default = ["200", "500"]
} #eg ["201", "400", "403", "404", "500"]
variable "api_key_required" {
  default = false
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${var.api_id}"
  parent_id = "${var.parent_id}"
  path_part = "${var.path}"
}

resource "aws_api_gateway_method" "method" {
  count =  "${length(var.api_methods)}"
  rest_api_id = "${var.api_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${element(var.api_methods, count.index)}"
  authorization = "NONE"
  api_key_required = "${var.api_key_required}"
}

resource "aws_api_gateway_integration" "integration" {
  count = "${length(var.api_methods)}"
  rest_api_id = "${var.api_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${element(aws_api_gateway_method.method.*.http_method, count.index)}"
  type = "AWS_PROXY"
  integration_http_method = "POST" #Its a 'quirk' of lambda that it needs to be invoked this way
  credentials = "${var.gateway_lambda_execution_role_arn}"
  # This is some hard-coded path that AWS specifies. No idea what the date means
  # See: http://docs.aws.amazon.com/lambda/latest/dg/with-on-demand-https-example-configure-event-source.html
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda_function_name}/invocations"
}

resource "aws_api_gateway_method_response" "response_codes" {
  count = "${length(var.response_codes) * length(var.api_methods)}"
  rest_api_id = "${var.api_id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${element(aws_api_gateway_method.method.*.http_method, count.index)}"
  status_code = "${element(var.response_codes, count.index)}"
}