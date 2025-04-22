terraform {
  required_version = "1.11.2"

}

provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
