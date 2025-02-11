resource "aws_iam_openid_connect_provider" "oidc-git" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [
    "d89e3bd43d5d909b47a18977aa9d5ce36cee184c"
  ]
  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "ecr-role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "arn:aws:iam::525883733118:oidc-provider/token.actions.githubusercontent.com"
        },
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ],
            "token.actions.githubusercontent.com:sub" : [
              "repo:rodrigofontesdev/hello-world-api:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role" "app-runner-role" {
  name = "app-runner-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "build.apprunner.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    IAC = "True"
  }
}

resource "aws_iam_role_policy_attachment" "app-runner-policy-attachment" {
  role       = aws_iam_role.app-runner-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy" "ecr-policy" {
  name = "ecr-app-permission"
  role = aws_iam_role.ecr-role.id

  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Sid"      = "Statement0"
        "Action"   = "apprunner:*"
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Sid" = "Statement1"
        "Action" = [
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Sid" = "Statement2"
        "Action" = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      }
    ]
  })
}
