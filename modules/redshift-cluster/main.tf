
resource "aws_vpc" "redshift_vpc" {

  cidr_block       = var.VPC_CIDR
  instance_tenancy = "default"
  tags = {
    Name = "redshift-vpc"

  }

}

resource "aws_internet_gateway" "redshift_vpc_gw" {
  vpc_id = aws_vpc.redshift_vpc.id
}


resource "aws_route_table" "vpc_route_table" {
  vpc_id = aws_vpc.redshift_vpc.id
  tags = {
    "Name" = "main_route_table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.redshift_vpc_gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.redshift_vpc_gw.id
  }

}



resource "aws_security_group" "redshift_security_group" {

  vpc_id = aws_vpc.redshift_vpc.id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["${var.KINESIS_CIDR}"]
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "redshift-sg"
  }
  

}



resource "aws_subnet" "redshift_subnet_1" {
  vpc_id                  = aws_vpc.redshift_vpc.id
  cidr_block              = var.VPC_SUBNET_1
  availability_zone       = "us-west-1c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "redshift-subnet-1"
  }
}



resource "aws_subnet" "redshift_subnet_2" {
  vpc_id                  = aws_vpc.redshift_vpc.id
  cidr_block              = var.VPC_SUBNET_2
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "redshift-subnet-2"
  }
}
resource "aws_route_table_association" "association_pub_a" {
  subnet_id      = aws_subnet.redshift_subnet_1.id
  route_table_id = aws_route_table.vpc_route_table.id
}

resource "aws_route_table_association" "association_pub_b" {
  subnet_id      = aws_subnet.redshift_subnet_2.id
  route_table_id = aws_route_table.vpc_route_table.id
}




resource "aws_redshift_subnet_group" "redshift_subnet_group" {

  name       = "redshift-subnet-group"
  subnet_ids = ["${aws_subnet.redshift_subnet_1.id}", "${aws_subnet.redshift_subnet_2.id}"]

  tags = {
    environment = "devel"
    Name        = "sg12-redshift-subnet-group"
  }

}


//This role will allow our cluster to read and write to any of our S3 bucket.

resource "aws_iam_policy" "s3_full_access_policy" {
  name   = "redshift_s3_policy"
 
  policy = <<EOF
{

   "Version": "2012-10-17",
   "Statement": [
       {
          "Effect": "Allow",
          "Action": [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ],
          "Resource": "*"
       }
   ]
}
EOF

}


resource "aws_iam_role" "redshift_role" {
  name               = "sg12-redshift_role"
  assume_role_policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": [
          "firehose.amazonaws.com",
          "redshift.amazonaws.com"
        ]
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
    }
    EOF

  tags = {
    tag-key = "sg12-redshift-role"
  }

}


resource "aws_iam_role_policy_attachment" "redshift_policy_attachment_simple" {
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
  role       = aws_iam_role.redshift_role.name
}




/*
* Define the cluster
*/

resource "aws_redshift_cluster" "data_warehouse_cluster" {
  cluster_identifier = "sg12-redshift-cluster"
  database_name      = var.CLUSTER_DB_NAME
  master_username    = var.CLUSTER_USERNAME
  master_password    = var.CLUSTER_PASS
  node_type          = var.CLUSTER_NODE_TYPE
  cluster_type       = var.CLUSTER_TYPE
  cluster_subnet_group_name     = aws_redshift_subnet_group.redshift_subnet_group.id
  skip_final_snapshot           = true

  vpc_security_group_ids        = ["${aws_security_group.redshift_security_group.id}"]
  publicly_accessible           = true
  iam_roles                     = ["${aws_iam_role.redshift_role.arn}"]
  /*provisioner "local-exec" {
    command = "psql \"postgresql://${self.master_username}:${self.master_password}@${self.endpoint}/${self.database_name}\" -f ./redshift_table.sql"
  }*/
}



