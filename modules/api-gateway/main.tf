/*
get_Records
 uri = format(
    "arn:%s:apigateway:%s:kinesis:action/GetRecords",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )
shar get
  uri = format(
    "arn:%s:apigateway:%s:kinesis:action/ListShards",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )

sptreams get
  uri = format(
    "arn:%s:apigateway:%s:kinesis:action/ListStreams",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )

stream ger

  uri = format(
    "arn:%s:apigateway:%s:kinesis:action/DescribeStreamSummary",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )

record put
 uri = format(
    "arn:%s:apigateway:%s:kinesis:action/PutRecord",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )


records put
  uri = format(
    "arn:%s:apigateway:%s:kinesis:action/PutRecords",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )

sharditerator_get

  uri = format(
    "arn:%s:apigateway:%s:kinesis:action/GetShardIterator",
    data.aws_partition.current.partition,
    data.aws_region.current.name
  )
*/

/*

{
   "DeliveryStreamName": "sg12-kinesis-firehose-extended-s3-stream",
   "Record": { 
      "Data": "ewogICAiRGVsaXZlcnlTdHJlYW1OYW1lIjogInNnMTIta2luZXNpcy1maXJlaG9zZS1leHRlbmRlZC1zMy1zdHJlYW0iLAogICAiUmVjb3JkIjogeyAKICAgICAgIkRhdGEiOiAibWF0ZSBlIGNhbXBpb25hIgogICB9Cn0="
   }
}

{
   "DeliveryStreamName": "sg12-kinesis-firehose-extended-s3-stream",
   "Record": { 
      "Data": "eyAKICAgICJUSUNLRVJfU1lNQk9MIjogIlFYWiIsCiAgICAiU0VDVE9SIjogIkhFQUxUSENBUkUiLAogICAgIkNIQU5HRSI6IC0wLjA1LAogICAgIlBSSUNFIjogODQuNTEKfQ=="
   }
}
Once the REST API is configured, the aws_api_gateway_deployment resource 
can be used along with the aws_api_gateway_stage resource to publish the REST API.*/

data "aws_partition" "current" {}

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.APP_NAME}-rest-api-${var.ENVIROMENT}"
  description = "Api Gateway that will proxy for a KInessis"
}


/*
* Declaring the resource
*/

resource "aws_api_gateway_resource" "api" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "streams"
  rest_api_id = aws_api_gateway_rest_api.api.id
}



/*
* GET Delivery Streams from Kinesis
*/

resource "aws_api_gateway_method" "streams_get" {
  authorization = "none"
  http_method   = "GET"

  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.api.id
  request_validator_id = aws_api_gateway_request_validator.api.id
}



resource "aws_api_gateway_method_response" "streams_get_200" {

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.streams_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}




resource "aws_api_gateway_integration" "streams_get" {

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.streams_get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri = format(
    "arn:%s:apigateway:%s:firehose:action/ListDeliveryStreams",
    data.aws_partition.current.partition,
    var.AWS_REGION
  )


  credentials = aws_iam_role.api-gateway-to-kinesis-role.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-amz-json-1.1'"
  }
  request_templates = {
    "application/json" = jsonencode({})
  }
}


resource "aws_api_gateway_integration_response" "streams_get" {

  rest_api_id         = aws_api_gateway_rest_api.api.id
  resource_id         = aws_api_gateway_resource.api.id
  http_method         = aws_api_gateway_method.streams_get.http_method
  status_code         = aws_api_gateway_method_response.streams_get_200.status_code
  response_parameters = {}
}


/*
*  END GET Streams
*/


/*
* PUT into Delivery Streams for Kinesis
*/
resource "aws_api_gateway_method" "records_put" {
  authorization = "none"
  http_method   = "PUT"
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_resource.api.id
}



resource "aws_api_gateway_method_response" "records_put_200" {

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.records_put.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {}
}

resource "aws_api_gateway_integration" "records_put" {

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.records_put.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri = format(
    "arn:%s:apigateway:%s:firehose:action/PutRecord",
    data.aws_partition.current.partition,
    var.AWS_REGION
  )


  credentials = aws_iam_role.api-gateway-to-kinesis-role.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-amz-json-1.1'"
  }
 /* request_templates = {
    "application/json" = <<EOT
    {
      "StreamName": "$input.params('stream-name')",
      "Records": [
       #foreach($elem in $input.path('$.records'))
          {
            "Data": "$util.base64Encode($elem.data)",
            "PartitionKey": "$elem.partition-key"
          }#if($foreach.hasNext),#end
        #end
    ]
    }
    EOT
  }*/
}

resource "aws_api_gateway_integration_response" "records_put" {

  rest_api_id         = aws_api_gateway_rest_api.api.id
  resource_id         = aws_api_gateway_resource.api.id
  http_method         = aws_api_gateway_method.records_put.http_method
  status_code         = aws_api_gateway_method_response.records_put_200.status_code
  response_parameters = {}
}

/*
* END PUT into Delivery Streams for Kinesis
*/








/*
*Declare the deployment
*/

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api.id,
      aws_api_gateway_method.streams_get.id,
      aws_api_gateway_integration.streams_get.id,
      aws_api_gateway_method.records_put.id,
      aws_api_gateway_integration.records_put.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_integration.streams_get
  ]
}




/*
* Declaring the stage
*/
resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "${var.APP_NAME}-${var.ENVIROMENT}-stage"
}



/*
* Validator
*/
resource "aws_api_gateway_request_validator" "api" {
  name                        = "Validate query string parameters and headers"
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  validate_request_body       = false
  validate_request_parameters = true
}













/*
* Role to be assumend by APi Gateway when posting to Kinesis
*/

resource "aws_iam_role" "api-gateway-to-kinesis-role" {
  name = "api-gateway-to-kinesis-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

}

/*
* Policy for the role
*/

resource "aws_iam_policy" "api-gateway-to-kinesis-role-policy" {
  name = "api-gateway-to-kinesis-role-policy"

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
        "Action": "firehose:*",
        "Resource": "${var.KINESSIS_DF_ARN}"
      },
      {
        "Effect": "Allow",
        "Action": "kinesis:*",
        "Resource": "${var.KINESSIS_DF_ARN}"
      },
      {
        "Effect": "Allow",
        "Action": "kinesis:ListStreams",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "firehose:ListDeliveryStreams",
        "Resource": "*"
      }       
    ]
}
EOF
}
/*
*  Attach policty to Role
*/


resource "aws_iam_role_policy_attachment" "api" {
  role       = aws_iam_role.api-gateway-to-kinesis-role.name
  policy_arn = aws_iam_policy.api-gateway-to-kinesis-role-policy.arn
}
