variable "ENVIROMENT" {
  default     = "production"
  description = "enviroment"
}

variable "APP_NAME" {
  default     = "production"
  description = "enviroment"
}

variable "AWS_REGION" {
    type=string
}


variable "KINESSIS_DF_ARN"{
    type = string
}


variable "KINESSIS_DF_NAME"{
    type = string
}