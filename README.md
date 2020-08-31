# AWS VPC Interface Endpoint DNS demo

A demo to show how AWS DNS listen responds differently when a VPC interface endpoint has been created.

When a VPC endpoint is created, api requests should to use that endpoint, rather than the public endpoint. This improves security, because AWS resources deployed on our VPC do not need to have internet access (via a route to 0.0.0.0/0) to make API calls.

Most systems deployed on AWS resources need to make API requests to AWS services. For instance, it may be necessary for the system to be able to check a volume attachment is available (`aws ec2 describe-volumes...`).

Steps:

# 1. Create a demo network

This is minimal. A subnet. Note we configure a DHCP option set and attach it to the VPC. A default security group and NACL are created, which are permissive for egress (and ingress for the NACL).

# 2. Add an Internet gateway

Add internet gateway so resources can reach the Internet. This is a seperate stack, because we'll remove it later.

# 3. Create an instance

Creates an instance. It has a security group (so for clarity, we won't use the default security group), which has a default egress rule, so outbound connections are allows. We'll then access the instance and examine its DNS setup (which it learned from the DHCP option set). The instance as an AWS role which allows it to make requests to the AWS SSM service, which uses ec2messages, ssm, ssmmessages, and also to call the EC2 API call, describe instances (I might want to find out about attached volumes - that command will tell me).

The instance user-data installs a utilities: nmap, bind-utils, tmux, tcpdump, which we might need.

# 4. Lets log !

Im using the EC2 Session manager for login.

As you can see resolv.conf is set from the DHCP options, and AmazonDNS is used.

```bash
cat /etc/resolv.conf
```

Lets make an API request (which we have permission to do):

```bash
aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --region ap-southeast-2
```

Consider the API request for a second. What does the API talk to. Lets do that again.

```bash
aws ec2 describe-instances --instance-ids $(curl -s http://169.254.169.254/latest/meta-data/instance-id) --endpont-url ec2.ap-southeast-2.amazonaws.com
```

ec2.ap-southeast-2.amazonaws.com resolves to a public endpoint. So we need to have Internet access to get to it, and a fairly open egress policy through security groups, NACLs etc. to get there. Any time I have an open egress policy, I have to consider if my service is compromised, one attack vector is to make an outbound connection (e.g. to a command and control, etc.)

```bash
# Forward lookup
dig +short ec2.ap-southeast-2.amazonaws.com

# Reverse lookup
dig +short -x $( dig +short ec2.ap-southeast-2.amazonaws.com )
```

If we repeat that from the Internet, we get the same result (a few caveats there relating to geo-location, but the answer is always a publicly reachable endpoint).

# 5. Endpoints

Lets install some interface endpoints, so we can access the AWS API via those, and eliminate our need for internet access. I'm installing two endpoints. One for SSM (so I can still have console access for the demo) and one for EC2, so I can repeat the commands.

> My EC2 instance now has all the software it needs, because we set that up while we had Intenet access. Golden AMIs, container images - bascially build your solution somewhere else where it's easy, and then deploy it, and automate that so you can keep it updated.
