variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "url-shortener"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "url_shortener_table"
}

variable "s3_bucket" {
  description = "S3 bucket name where the app code gets pushed from Github Actions"
  type        = string
}

variable "s3_key" {
  description = "S3 object key for the lambda deployment zip"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "url_shortener_function"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_handler" {
  description = "Lambda function entry point"
  type        = string
  default     = "index.handler"
}

variable "auth_token" {
  description = "Auth token for basic protection"
  type        = string
  default     = "changeme-token"
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}