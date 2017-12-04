# Variable to store HTTP Server Port
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

# Variable to store AWS Region
variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-2"
}

# Variable to store AWS IAM Access Key
variable "aws_access_key" {
  description = "The AWS Access Key to acccess."
  default     = "<ACCESS_KEY>"
}

# Variable to store AWS IAM Secret Key
variable "aws_secret_key" {
  description = "The AWS Secret Key"
  default     = "<SECRET_KEY>"
}

# Variable to store Key Pair name
variable "aws_key_name" {
  description = "The AWS Key Pair"
  default     = "umgKey"
}




