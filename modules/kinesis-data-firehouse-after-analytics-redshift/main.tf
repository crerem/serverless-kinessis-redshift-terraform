/*
* Define the Kinessis Data firehouse
*/



resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "sg12-kinesis-firehose-processed-s3-stream"
  destination = "redshift"

  s3_configuration {
    role_arn           = aws_iam_role.kinesis_firehose_role.arn
    bucket_arn         = aws_s3_bucket.bucket.arn
    buffer_size        = 5
    buffer_interval    = 60

  }



  redshift_configuration {
    role_arn           = aws_iam_role.kinesis_firehose_role.arn
    cluster_jdbcurl    = "jdbc:redshift://${var.REDSHIFT_ENDPOINT}/${var.REDSHIFT_DB_NAME}"
    username           =  var.CLUSTER_USERNAME
    password           = var.CLUSTER_PASS
    data_table_name    = var.CLUSTER_TABLE
    copy_options = "CSV"
    s3_backup_mode     = "Disabled"
   
  }
}




/*
* Bucketes
*/


resource "aws_s3_bucket" "bucket" {
  bucket = "sg12-tf-processed-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}



/*
* Kinessis Roles
*/

resource "aws_iam_role" "kinesis_firehose_role" {
  name = "kinesis_processed_firehose_role"

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
  name = "kinesis_processed_firehose_policy"

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
        "Effect": "Allow",
        "Action": [
          "redshift:Copy*",
          "redshift:Describe*",
          "redshift:Execute*",
          "redshift:List*"
        ],
        "Resource": "${var.REDSHIFT_ARN}"
      }
    ]
}
EOF
}

/*
*  Attach policty to Role
*/


resource "aws_iam_role_policy_attachment" "kinesis_processed_policy_to_role" {
  role       = aws_iam_role.kinesis_firehose_role.name
  policy_arn = aws_iam_policy.kinesis_firehose_policy.arn
}

