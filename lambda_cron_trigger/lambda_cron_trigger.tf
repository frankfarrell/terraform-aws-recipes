######################################
#  http://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
#####################################

variable "unique_identifier" {}
variable "lambda_arn" {}
variable "description" {
  default = "Cron trigger"
}

variable minutes{
  default = "*"
  description = "0-59 - * / "
}
variable hours {
  default = "*"
  description = "0-23 - * / "
}
variable day_of_month {
  default = "*"
  description = "1-31 - * ? / L W "
}
variable month {
  default = "*"
  description = "1-12 or JAN-DEC - * / "
}
# You can't specify the Day-of-month and Day-of-week fields in the same cron expression. If you specify a value (or a *) in one of the fields, you must use a ? (question mark) in the other.
variable day_of_week {
  default = "?"
  description = "1-7 or SUN-SAT - * ? / L # "

}
variable year {
  default = "*"
  description = "1970-2199 - * / "
}

resource "aws_cloudwatch_event_rule" "cron_trigger" {
  name = "cron-trigger-${var.unique_identifier}"
  description = "${var.description}"
  schedule_expression = "cron(${var.minutes} ${var.hours} ${var.day_of_month} ${var.month} ${var.day_of_week} ${var.year})"
}

resource "aws_cloudwatch_event_target" "triger_new_table_end_of_month" {
  rule = "${aws_cloudwatch_event_rule.cron_trigger.name}"
  target_id = "triggerLambdaCron"
  arn = "${var.lambda_arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_dynamo_partitioning_lambda" {
  statement_id = "AllowExecutionFromCloudWatch-${var.unique_identifier}"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_arn}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.cron_trigger.arn}"
}
