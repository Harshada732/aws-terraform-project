resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "project-web-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public_subnet.id

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<EOF
#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2

echo "<h1>Enterprise AWS Infrastructure</h1>
<h2>Built with Terraform & AWS Cloud</h2>
<p>This project demonstrates a production-ready cloud architecture using Infrastructure as Code.</p>
<p>Services Used: VPC | EC2 | ALB | Auto Scaling | IAM | S3 | CloudWatch</p>
<h3>DevOps & Cloud Engineering Project</h3>"  > /var/www/html/index.html
EOF

  tags = {
    Name = "Terraform-EC2"
  }
}

resource "aws_s3_bucket" "project_bucket" {
  bucket = "terraform-project-demo-2026-harshada"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    InstanceId = aws_instance.my_ec2.id
  }

  alarm_description = "Alarm when CPU exceeds 80%"
}
resource "aws_lb" "app_alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.web_sg.id]

  subnets = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "terraform-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
resource "aws_launch_template" "app_lt" {
  name_prefix   = "terraform-lt"
  image_id      = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2

echo "<h1>Enterprise AWS Infrastructure</h1>" > /var/www/html/index.html
EOF
)
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}
resource "aws_db_subnet_group" "main" {
  name = "terraform-db-subnet-group"

  subnet_ids = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

resource "aws_db_instance" "mysql_db" {
  identifier     = "terraform-mysql-db"
  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = "projectdb"
  username = "adminuser"
  password = "Terraform123"

  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}