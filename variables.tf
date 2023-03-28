variable "AWS_REGION" {
  default     = "us-west-1"
  description = "aws region"
}

variable "profile" {
  default = "default"
}


variable "APP_NAME" {
  default     = "SG12-Serverless-processing-event"
  description = "application name"
}

variable "ENV" {
  default     = "production"
  description = "enviroment"
}

  
variable "TF_CLOUD_ORGANIZATION" {
  default     = "curlycloud"
  description = "terraform organization"
}
  
variable "TF_CLOUD_WORKSPACE" {
  default     = "serverlles-event-processing-pattern"
  description = "terrafrom serverless event processing"
}  

variable "AWS_SECRET_ACCESS_KEY" {
  default     = "AWS_SECRET_ACCESS_KEY"
  description = "need to setup this in terraform cloud workspace"
}

variable "AWS_ACCESS_KEY_ID" {
  default     = "AWS_ACCESS_KEY_ID"
  description = "need to setup this in terraform cloud workspace"
}


variable "VPC_CIDR" {
  default     = "10.0.0.0/16"
  description = "redshift VPC"
}


variable "VPC_SUBNET_1" {
  default     = "10.0.1.0/24"
  description = "redshift subnet 1"
}


variable "VPC_SUBNET_2" {
  default     = "10.0.2.0/24"
  description = "redshift subnet 2"
}


variable "KINESIS_CIDR" {
  default     = "13.57.135.192/27"
  description = "kinesis firehouse ip"
}

variable "CLUSTER_DB_NAME" {
 default     = "demo_cluster_dbname"
  description = "db name"
}

variable "CLUSTER_TABLE" {
  default     = "demo_cluster_dbtable"
  description = "db table name"
}

variable "CLUSTER_USERNAME" {
  default     = "masterusername"
  description = "cluster username"
}

variable "CLUSTER_PASS" {
  default     = "masterPass1"
  description = "cluster pass"
}

variable "CLUSTER_NODE_TYPE" {
  default     = "dc2.large"
  description = "cluster node type"
}

variable "CLUSTER_TYPE" {
 default     = "single-node"
  description = "cluster type (single or mult) "
}
