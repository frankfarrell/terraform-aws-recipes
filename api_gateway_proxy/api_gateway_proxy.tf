//Root REST resource
variable "api_name" {
  default = "test"
}
variable "api_description" {
  default = "Test api"
}

variable "stage_name" {
  default = "dev"
}
variable "stage_description" {
  default = "development api"
}

variable "account_id" {}
variable "region" {
  default = "us-east-1"
}
# This can be the arn or the name.
# In the case of an aliased function, it must be functionName:alias
variable "lambda_function_name" {}
variable "gateway_lambda_execution_role_arn" {}
variable "api_methods" {
  type = "list"
  default = ["GET"]
} #eg ['POST', 'GET']
variable "response_codes" {
  type = "list"
  default = ["200", "500"]
} #eg ["201", "400", "403", "404", "500"]

# If true the output will be passed as an output
variable "create_api_key" {
  default = false
}
variable "path" {
  default = "{proxy+}"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}"
}
output "api_execution_arn" {
  value = "${aws_api_gateway_deployment.deployment.execution_arn}"
}

output "api_key" {
  depends_on  = ["aws_api_gateway_api_key.api_key"]
  sensitive   = true
  value       = "${aws_api_gateway_api_key.api_key.value}"
}

resource "aws_api_gateway_rest_api" "api" {
  name            = "${var.api_name}"
  description     = "${var.api_description}"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on      = ["module.proxy"]
  rest_api_id     = "${aws_api_gateway_rest_api.api.id}"
  stage_name      = "${var.stage_name}"
  stage_description
                  = "${var.stage_description}"

  provisioner "local-exec" {
    command       = "sleep 20"
  }
}

module "proxy" {
  source          = "proxy"

  account_id      = "${var.account_id}"
  region          = "${var.region}"
  lambda_function_name
                  = "${var.lambda_function_name}"
  gateway_lambda_execution_role_arn
                  = "${var.gateway_lambda_execution_role_arn}"
  stage           = "${var.stage_name}"
  parent_id       = "${aws_api_gateway_rest_api.api.root_resource_id}"
  api_id          = "${aws_api_gateway_rest_api.api.id}"
  api_methods      = "${var.api_methods}"
  response_codes  = "${var.response_codes}"
  api_key_required = "${var.create_api_key}"
  path            = "${var.path}"
}

# Ideally following would be in a module, but TF doesnt support count on modules:
# https://github.com/hashicorp/terraform/issues/953
resource "aws_api_gateway_api_key" "api_key" {
  count           = "${var.create_api_key}"
  name          = "${var.api_name}-${var.stage_name}-api-key"
  description   = "API Key for to access endpoints"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  count           = "${var.create_api_key}"
  key_id        = "${aws_api_gateway_api_key.api_key.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.usage_plan.id}"
}


resource "aws_api_gateway_usage_plan" "usage_plan" {
  count           = "${var.create_api_key}"
  depends_on      = ["aws_api_gateway_deployment.deployment"]
  name          = "${var.api_name}-${var.stage_name}-usage-plan"
  description   = "Description here"

  api_stages {
    api_id      = "${aws_api_gateway_rest_api.api.id}"
    stage       = "${var.stage_name}"
  }
}