

resource "aws_cloudwatch_log_group" "example" {
  name = "analytics"
}

resource "aws_cloudwatch_log_stream" "example" {
  name           = "example-kinesis-application"
  log_group_name = aws_cloudwatch_log_group.example.name
}


// kinesis-analytics-CretuSample-us-west-1 with required policies

resource "aws_kinesis_analytics_application" "test" {
  name              = "example-application"
  start_application = false
  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.example.arn
    role_arn       = aws_iam_role.kinesis_analytics_role.arn
  }


   code = <<-EOT
        CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" ("speed" DOUBLE, "rpm" INTEGER, "gear" INTEGER, "throttle" DOUBLE);
        CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
        SELECT STREAM "speed", "rpm", "gear", "throttle"
        FROM "sg12_prefix_001"
        WHERE "speed" >= 200;
    EOT

  inputs {
    name_prefix = "sg12_prefix"


    kinesis_firehose {
      resource_arn = var.KINESIS_FIREHOUSE_ARN
      role_arn     = aws_iam_role.kinesis_analytics_role.arn
    }

    starting_position_configuration {
      starting_position = "NOW"
    }



    schema {
      record_encoding = "UTF-8"


      record_format {
        mapping_parameters {
          json {
            record_row_path = "$"
          }
        }
      }

      record_columns {
        mapping  = "$.speed"
        name     = "speed"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.rpm"
        name     = "rpm"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.gear"
        name     = "gear"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.throttle"
        name     = "throttle"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.brakes"
        name     = "brakes"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.steering_angle"
        name     = "steering_angle"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.suspension.ride_height"
        name     = "ride_height"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.suspension.damper_settings.front_left"
        name     = "front_left"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.suspension.damper_settings.front_right"
        name     = "front_right"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.suspension.damper_settings.rear_left"
        name     = "rear_left"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.suspension.damper_settings.rear_right"
        name     = "rear_right"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.engine"
        name     = "engine"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.brakes.front_left"
        name     = "front_left0"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.brakes.front_right"
        name     = "front_right0"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.brakes.rear_left"
        name     = "rear_left0"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.brakes.rear_right"
        name     = "rear_right0"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.tires.front_left"
        name     = "front_left1"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.tires.front_right"
        name     = "front_right1"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.tires.rear_left"
        name     = "rear_left1"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.temperatures.tires.rear_right"
        name     = "rear_right1"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.pressures.engine"
        name     = "engine0"
        sql_type = "DECIMAL"
      }

      record_columns {
        mapping  = "$.pressures.brakes.front_left"
        name     = "front_left2"
        sql_type = "INTEGER"
      }


      record_columns {
        mapping  = "$.pressures.brakes.front_right"
        name     = "front_right2"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.pressures.brakes.rear_left"
        name     = "rear_left2"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.pressures.brakes.rear_right"
        name     = "rear_right2"
        sql_type = "INTEGER"
      }


      record_columns {
        mapping  = "$.pressures.tires.front_left"
        name     = "front_left3"
        sql_type = "DECIMAL"
      }

      record_columns {
        mapping  = "$.pressures.tires.front_right"
        name     = "front_right3"
        sql_type = "DECIMAL"
      }



      record_columns {
        mapping  = "$.pressures.tires.rear_left"
        name     = "rear_left3"
        sql_type = "DECIMAL"
      }


      record_columns {
        mapping  = "$.pressures.tires.rear_right"
        name     = "rear_right3"
        sql_type = "DECIMAL"
      }



      record_columns {
        mapping  = "$.fuel_consumption"
        name     = "fuel_consumption"
        sql_type = "DECIMAL"
      }

      record_columns {
        mapping  = "$.lap_time"
        name     = "lap_time"
        sql_type = "DECIMAL"
      }
     /* */
    }
  } 
  outputs {
    name = "DESTINATION_SQL_STREAM"

    schema {
      record_format_type = "CSV"
    }

    kinesis_firehose {
      resource_arn = var.KINESIS_OUTPUT_FIREHOUSE_ARN
      role_arn     = aws_iam_role.kinesis_analytics_role.arn
    }
  }


}




/*
* Kinessis Roles
*/

resource "aws_iam_role" "kinesis_analytics_role" {
  name = "kinesis_analytics_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_policy" "kinesis_analytics_policy" {
  name = "kinesis_analytics_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "WriteOutputFirehose",
            "Effect": "Allow",
            "Action": [
                "firehose:DescribeDeliveryStream",
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": [
                "${var.KINESIS_OUTPUT_FIREHOUSE_ARN}"
            ]
        },
        {
            "Sid": "ReadInputFirehose",
            "Effect": "Allow",
            "Action": [
                "firehose:DescribeDeliveryStream",
                "firehose:Get*"
            ],
            "Resource": [
                "${var.KINESIS_FIREHOUSE_ARN}"
            ]
        },  
        {
            "Sid": "ReadS3Data",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "${var.KINESIS_FIREHOUSE_BUCKET_ARN}"
            ]
        }
    ]
}
EOF
}

/*
*  Attach policty to Role
*/


resource "aws_iam_role_policy_attachment" "kinesis_analytics_policy_to_role" {
  role       = aws_iam_role.kinesis_analytics_role.name
  policy_arn = aws_iam_policy.kinesis_analytics_policy.arn
}


