resource "aws_cloudwatch_dashboard" "times-saving-api-dashboard" {
  dashboard_name = "Times-Saving-API-${var.environment}"
  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "saving-api-aurora-instance-${var.environment}-0", { "period": 60 } ],
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "saving-api-aurora-instance-${var.environment}-1", { "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "title": "RDS CPU Utilization",
                "region": "eu-west-1",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "times-saving-api-${var.environment}-app", { "period": 60, "stat": "Sum" } ],
                    [ "...", "times-saving-api-${var.environment}-authorizer", { "period": 60, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-1",
                "title": "Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 12,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "times-saving-api-${var.environment}-app", { "period": 60, "stat": "Sum" } ],
                    [ "...", "times-saving-api-${var.environment}-authorizer", { "period": 60, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-1",
                "title": "Invocation Errors",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "4XXError", "ApiName", "${var.environment}-times-saving-api", { "period": 60, "stat": "Sum" } ],
                    [ ".", "5XXError", ".", ".", { "period": 60, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "title": "4xx & 5xx Errors",
                "region": "eu-west-1",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 18,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "times-saving-api-${var.environment}-app", { "period": 60 } ],
                    [ "...", "times-saving-api-${var.environment}-authorizer", { "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "title": "Durations",
                "region": "eu-west-1",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 18,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Throttles", "FunctionName", "times-saving-api-${var.environment}-app", { "period": 60, "stat": "Sum" } ],
                    [ "...", "times-saving-api-${var.environment}-authorizer", { "period": 60, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-1",
                "period": 300
            }
        }
    ]
}
 EOF
}