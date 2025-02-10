resource "aws_ecr_repository" "hello-world-api" {
  name                 = "hello-world-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    IAC = "True"
  }
}
