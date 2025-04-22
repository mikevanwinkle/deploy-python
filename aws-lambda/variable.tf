

variable "region" {
  default = "us-west-1"
}

variable "lambda_function_name" {
  default = "demo-api"
}

variable "stage" {
  default = "api"
}

variable "domain_name" {
  type    = string
  default = "yourdomain.com"
}

variable "env" {
  type    = string
  default = "dev"

}

variable "project" {
  type    = string
  default = "demo-api"
}

variable "lambda_layer_filename" {
  type    = string
  default = "layer.zip"
}

variable "lambda_filename" {
  type    = string
  default = "function.zip"
}

variable "hosted_zone_name" {
  type = string
}
