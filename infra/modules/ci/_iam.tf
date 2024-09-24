data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.github_actions.certificates[0].sha1_fingerprint
  ]
}

resource "aws_iam_role" "github_action" {
  name = "for-github-action"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.github_actions.arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_username}/${var.github_repo}:*"
          }
        }
      }
    ]
  })
  description = "Allow GitHub Action user to upload artifacts to S3"
}

resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  role       = aws_iam_role.github_action.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy" "allow_s3_limited_access" {
  role = aws_iam_role.github_action.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [
          "${var.webapp_s3_bucket_arn}",
          "${var.webapp_s3_bucket_arn}/*"
        ]
        Action = "s3:*"
      },
      {
        Effect = "Allow"
        Resource = "${var.webapp_cloudfront_distribution_arn}",
        Action = [
          "cloudfront:CreateInvalidation"
        ]
      },
      {
        Effect = "Allow"
        Resource = "${var.blog_api_function_arn}"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunctionConfiguration"
        ]
      }
    ]
  })
}