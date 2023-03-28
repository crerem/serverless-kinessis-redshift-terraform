output "sg12_aws_kinesis_firehose_arn" {
  value=aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}

output "sg12_aws_kinesis_firehose_name" {
  value=aws_kinesis_firehose_delivery_stream.extended_s3_stream.name
}

output "sg12_aws_kinesis_firehouse_bucket_arn" {
  value= aws_s3_bucket.bucket.arn
}

output "sg12_aws_kinesis_firehouse_lambda_arn" {
  value= aws_lambda_function.lambda_processor.arn
}