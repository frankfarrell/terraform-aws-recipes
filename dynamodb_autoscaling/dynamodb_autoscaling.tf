variable "max_capacity" {}
variable "min_capacity" {}
variable "target_utilization" {
  default = 0.7
}
variable table_name {}
variable dynamo_autoscale_role_arn {}
variable type {
  default = "READ"
  description = "Options are READ or WRITE"
}

resource "aws_appautoscaling_target" "dynamodb_table_target" {
  max_capacity       = "${var.max_capacity}"
  min_capacity       = "${var.min_capacity}"
  resource_id        = "table/${var.table_name}"
  role_arn           = "${var.dynamo_autoscale_role_arn}"
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

    # Trick to get terraform interpolation to work with floats
    target_value = "${ 1.0 * var.max_capacity *  (1.0 * var.target_utilization)  }"
  }
}