# Create SG to accept traffic from worker VM
resource "aws_security_group" "week10-https-sg" {
    name = "week10-https-sg"
    description = "Allow traffic from ssh SG over port 443"
    vpc_id = aws_vpc.week10-vpc.id

    ingress = [
        {
            description = "HTTP from bastion to worker node"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks      = []
            security_groups  = [aws_security_group.week10-ssh-pri-sg.id]
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            self = false
        }
    ]

    # TODO: This egress might not be needed but the worker node hangs on aws cli commands. This 
    # will allow outbound traffic, but might be insecure in a real-world scenario because data
    # stolen can be exfiltrated to the internet. Delete if not needed
    egress = [
        {
            description = "All traffic from worker node to bastion"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]

            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
        }
    ]
}

# Create an EC2 endpoint
resource "aws_vpc_endpoint" "week10-ec2-ep" {
    vpc_id = aws_vpc.week10-vpc.id
    service_name = "com.amazonaws.us-east-1.ec2"
    vpc_endpoint_type = "Interface"
    security_group_ids = [aws_security_group.week10-https-sg.id]
    private_dns_enabled = true
    subnet_ids = [aws_subnet.week10-pri-a.id, aws_subnet.week10-pri-b.id]

    tags = {
        name = "week10-ec2-ep"
    }
}

# Create an SQS endpoint
resource "aws_vpc_endpoint" "week10-sqs-ep" {
    vpc_id = aws_vpc.week10-vpc.id
    service_name = "com.amazonaws.us-east-1.sqs"
    vpc_endpoint_type = "Interface"
    security_group_ids = [aws_security_group.week10-https-sg.id]
    private_dns_enabled = true
    subnet_ids = [aws_subnet.week10-pri-a.id, aws_subnet.week10-pri-b.id]

    tags = {
        name = "week10-sqs-ep"
    }
}

