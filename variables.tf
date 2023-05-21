variable "awsRegion" {
  type        = string
  description = "aws region"
}

variable "vpcCidr" {
  type        = string
  description = "cidr block for vpc"
}

variable "vpcName" {
  type        = string
  description = "name for vpc"
}

variable "igwName" {
  type        = string
  description = "name for internet gate way"
}

variable "anyIP" {
  type        = string
  description = "any ip var variable 0.0.0.0/0 "
}

variable "publicRouteTableName" {
  type        = string
  description = "public Route Table Name "
}

variable "subnetsCidr" {
  type        = list(string)
  description = "cider for puublic subnet then private"
}

variable "subnetsNames" {
  type        = list(string)
  description = "Names for public subnet then private"
}

variable "instanceType" {
  type        = string
  description = "instance_type of ec2"
}
