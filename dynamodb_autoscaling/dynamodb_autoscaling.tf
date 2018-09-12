variable "max_capacity" {}
variable "min_capacity" {}
variable "target_utilization" {
  default = 0.7
}
variable table_name {}
variable type {
  default = "READ"
  description = "Options are READ or WRITE"
}
variable account_id {}

resource "aws_appautoscaling_target" "dynamodb_table_target" {
  max_capacity       = "${var.max_capacity}"
  min_capacity       = "${var.min_capacity}"
  resource_id        = "table/${var.table_name}"
  role_arn           = "arn:aws:iam::${var.account_id}:role/aws-service-role/dynamodb.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_DynamoDBTable"
  scalable_dimension = "dynamodb:table:${var.type == "READ" ? "ReadCapacityUnits" : "WriteCapacityUnits"}"
  service_namespace  = "dynamodb"
}


resource "aws_appautoscaling_policy" "dynamodb_table_policy" {
  name               = "DynamoDB${var.type == "READ" ? "Read" : "Write"}CapacityUtilization:${aws_appautoscaling_target.dynamodb_table_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.dynamodb_table_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.dynamodb_table_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.dynamodb_table_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDB${var.type == "READ" ? "Read" : "Write"}CapacityUtilization"
    }

    # Trick to get terraform interpolation to wor
    target_value = "${1.0 * var.target_utilization}"
  }
}
