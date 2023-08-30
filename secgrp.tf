resource "aws_security_group" "vprofile-bean-elb-sg" {  #Beanstalk-ELB & Security Group Provisioning
  name = "vprofile-bean-elb-sg"
  description = "Security group for bean-elb"
  vpc_id = "module.vpc.vpc_id" #vpc_id Module from Terraform registry documentation

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  #Bastion-Host Security Group to Launch Bation Host

resource "aws_security_group" "vprofile-bastion-sg" {
  name = "vprofile-bastion-sg"
  description = "Security group for bastion provisioner ec2 instance" 
  vpc_id = module.vpc.vpc_id
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.MYIP]
  } 
}

#Security Group For Ec2 Instance In Beanstalk Environment
 
resource "aws_security_group" "vprofile-prod-sg" {
  name = "vprofile-prod-sg"
  description = "Security group for beanstalk ec2 instance" 
  vpc_id = module.vpc.vpc_id
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    security_groups = [aws_security_group.vprofile-bastion-sg.id]
  }
}

#Provisioning Backend Services RDS Database , RabbitMQ

resource "aws_security_group" "vprofile-backend-sg" {
  name = "vprofile-backend-sg"
  description = "Security group for RDS, active mq, elasticache" 
  vpc_id = module.vpc.vpc_id
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    security_groups = [aws_security_group.vprofile-prod-sg.id]
  }
}

resource "aws_security_group_rule" "sec_group_allow_itself" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  security_group_id = aws_security_group.vprofile-backend-sg.id
  source_security_group_id = aws_security_group.vprofile-prod-sg.id
}
