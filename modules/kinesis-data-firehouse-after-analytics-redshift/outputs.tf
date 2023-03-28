output "sg12_aws_kinesis_firehose_processed_arn" {
  value=aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}

output "sg12_aws_kinesis_firehose_processed_name" {
  value=aws_kinesis_firehose_delivery_stream.extended_s3_stream.name
}

output "sg12_aws_kinesis_firehouse_processed_bucket_arn" {
  value= aws_s3_bucket.bucket.arn
}
