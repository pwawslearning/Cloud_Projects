resource "aws_cloudwatch_log_group" "cw_log_group" {
  name = "cw_log_group_vpc_flowlogs"
  retention_in_days = 1
  log_group_class = "STANDARD"

  tags = {
    Name = "${var.tags}-cw"
  }
}