# Api Gateway intergrated with Lambda by Proxy

A terrafrom module for creating api gateways that intergrate with lambda via proxy. 

Prerequisites: 
1. A lambda is in place. See examples for a sample lambda that is called via proxy 

See http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html

This module can be used in two ways: 

## 1 As a complete standalone api gateway

```
module "api_gateway" {
  source = "github.com/frankfarrell/terraform-aws-recipes//api_gateway_proxy//api_gateway_proxy"
}
```

Attributes required: 
1. api_name & description
3. stage_name & description => eg dev, test or prod
1. account_id
2. region 
3. lambda_function_name => can be name, arn or name:alias
4. gateway_lambda_execution_role_arn => Arn of a role that has this policy: 
    
    ```{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "apigateway.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
5. api_methods => list of methods, default is GET
6. response codes => list of response, default is 200 & 500
7. create_api_key -> whether it should create a usage plan and api key

## 2 Intergate a proxy gateway endpoint into an existing api gateway

```
module "api_gateway" {
  source = "github.com/frankfarrell/terraform-aws-recipes//api_gateway_proxy//api_gateway_proxy//proxy"
}
```

Attributes as above and: 
1. parent_id    => An existing aws_api_gateway_rest_api.root_resource_id
2. api_id       => An existing aws_api_gateway_rest_api.id

What you can do further: 
1. Link it to a route 53 record