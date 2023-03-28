/*
* Define the Kinessis Data firehouse
*/


resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "sg12-kinesis-firehose-extended-s3-stream"
  destination = "extended_s3"



  extended_s3_configuration {
    role_arn        = aws_iam_role.kinesis_firehose_role.arn
    bucket_arn      = aws_s3_bucket.bucket.arn
    buffer_interval = 60
    buffer_size     = 5

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = "sg12/kinesisfirehose/kinesis-firehose-extended-s3-stream"
      log_stream_name = "customstream"

    }
  }


}






/*
* Bucketes
*/


resource "aws_s3_bucket" "bucket" {
  bucket = "sg12-tf-initial-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}



/*
* Kinessis Roles
*/

resource "aws_iam_role" "kinesis_firehose_role" {
  name = "kinesis_firehose_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_policy" "kinesis_firehose_policy" {
  name = "kinesis_firehose_policy"

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
        "Effect": "Allow",
        "Action": [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
        ],
        "Resource": "${aws_s3_bucket.bucket.arn}",
        "Resource": "${aws_s3_bucket.bucket.arn}/*"
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "lambda:InvokeFunction",
            "lambda:GetFunctionConfiguration"
        ],
        "Resource": "${aws_lambda_function.lambda_processor.arn}:$LATEST"
      }
    ]
}
EOF
}

/*
*  Attach policty to Role
*/


resource "aws_iam_role_policy_attachment" "kinesis_policy_to_role" {
  role       = aws_iam_role.kinesis_firehose_role.name
  policy_arn = aws_iam_policy.kinesis_firehose_policy.arn
}




















/*
* Define Processing Lambda  
*/

data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/hello.py"
  output_path = "${path.module}/hello.zip"
}



resource "aws_lambda_function" "lambda_processor" {
  filename         = data.archive_file.zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.zip.output_path)

  function_name = "firehose_lambda_processor"
  role          = aws_iam_role.lambda_iam_role.arn
  runtime       = "python3.8"
  handler       = "hello.lambda_handler"
  timeout       = 60

}



/*
* Lambda roles 
*/

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_iam_to_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_policy" "lambda_policy" {
  name = "api-gateway-to-sqs-role-policy_new"

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
        "Effect": "Allow",
        "Action": [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        "Resource": "${aws_s3_bucket.bucket.arn}"
      }
    ]
}
EOF
}

/*
*  Attach policty to Role
*/


resource "aws_iam_role_policy_attachment" "policy_to_role" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
