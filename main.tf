/*
*
*  Api Gateway
* 
*/

module "api-gateway" {
  source           = "./modules/api-gateway"
  ENVIROMENT       = var.ENV
  APP_NAME         = var.APP_NAME
  AWS_REGION       = var.AWS_REGION
  KINESSIS_DF_ARN  = module.kinessis-data-firehouse.sg12_aws_kinesis_firehose_arn
  KINESSIS_DF_NAME = module.kinessis-data-firehouse.sg12_aws_kinesis_firehose_name
}


module "kinessis-data-firehouse" {
  source     = "./modules/kinessis-data-firehouse"
  ENVIROMENT = var.ENV
  APP_NAME   = var.APP_NAME
}


module "kinesis-data-analytics" {
  source                       = "./modules/kinesis-data-analytics"
  ENVIROMENT                   = var.ENV
  APP_NAME                     = var.APP_NAME
  KINESIS_FIREHOUSE_ARN        = module.kinessis-data-firehouse.sg12_aws_kinesis_firehose_arn
  KINESIS_FIREHOUSE_BUCKET_ARN = module.kinessis-data-firehouse.sg12_aws_kinesis_firehouse_bucket_arn
  KINESIS_FIREHOUSE_LAMBDA_ARN = module.kinessis-data-firehouse.sg12_aws_kinesis_firehouse_lambda_arn

  KINESIS_OUTPUT_FIREHOUSE_ARN = module.kinesis-data-firehouse-after-analytics-redshift.sg12_aws_kinesis_firehose_processed_arn


}




module "kinesis-data-firehouse-after-analytics-redshift" {
  source            = "./modules/kinesis-data-firehouse-after-analytics-redshift"
  ENVIROMENT        = var.ENV
  APP_NAME          = var.APP_NAME
  REDSHIFT_ARN      = module.redshift-cluster.sg12_aws_redshift_cluster_arn
  REDSHIFT_ENDPOINT = module.redshift-cluster.sg12_aws_redshift_cluster_endpoint
  REDSHIFT_DB_NAME  = module.redshift-cluster.sg12_aws_redshift_cluster_database_name
  CLUSTER_USERNAME  = var.CLUSTER_USERNAME
  CLUSTER_PASS      = var.CLUSTER_PASS
  CLUSTER_TABLE     = var.CLUSTER_TABLE
}

module "redshift-cluster" {
  source            = "./modules/redshift-cluster"
  ENVIROMENT        = var.ENV
  APP_NAME          = var.APP_NAME
  VPC_CIDR          = var.VPC_CIDR
  VPC_SUBNET_1      = var.VPC_SUBNET_1
  VPC_SUBNET_2      = var.VPC_SUBNET_2
  KINESIS_CIDR      = var.KINESIS_CIDR
  CLUSTER_DB_NAME   = var.CLUSTER_DB_NAME
  CLUSTER_USERNAME  = var.CLUSTER_USERNAME
  CLUSTER_PASS      = var.CLUSTER_PASS
  CLUSTER_NODE_TYPE = var.CLUSTER_NODE_TYPE
  CLUSTER_TYPE      = var.CLUSTER_TYPE

}
