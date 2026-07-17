terraform {
    backend "s3" {
    bucket = "tf-statefile-roopaks76"
    key    = "ec2-devops-project/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}