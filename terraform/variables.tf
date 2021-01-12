variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "bucket_name" {
  type    = string
  default = "xistz-udagram-microservices-bucket"
}

variable "db_identifier" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
