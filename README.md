# terraform-aws-recipes
Collection of terraform modules for common aws resources

* Api gateway module  proxy
* Dynamodb autoscaling
* Cron Cloudwatch event to trigger lambda, with chef cron style format

### TODO
* Api gateway standard with RAML type configuration
* Kinesis with write access api keys
* Lambda with kinesis or dynamo streams source, with cloudwatch logging
* Autoscaling of lambda batch size?
* Autoscaling of kinesis shards based on cloudwatch events from lambda?
