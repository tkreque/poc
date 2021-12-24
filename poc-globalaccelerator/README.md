# POC AWS Global Accelerator

### Objective
Test the WAF rules using Global Accelerator to access an Application Load Balancer.

### Requirements
- Create ssh key into the AWS Account.
- Change the Public IPv4 to Whitelist in the WAF.

### Resources
- Network
  - VPC
  - IGW
  - 2 Public subnets
  - 2 Private subnets
- Application
  - EC2 with Apache and simple `index.html`
  - Target Group from port 80 to port 80
  - Application Load Balancer listening the port 80
  - Global Accelerator with 2 static public IPs
- Security
  - WAF with Default action of block
    - Whitelist rule

### Tests
A message similar to this one should be displayed in a success request.
``` 
It worked! ip-10-0-1-179.ec2.internal
```
In a failed request this message will appear.
```
403 Forbidden
```

### Procedure 
1. Add your IP into the EC2 Instance Security Group and access the EC2 Public DNS (Output `TestEc2DNS`).
2. Test the Public DNS from the ALB (Ouput `TestAlbDNS`).
3. Enable the Global Accelerator and test the Public DNS (Output `TestGaDNS`)
4. Change the IP in the WAF Rule and test again the steps 1, 2 and 3.
5. Perform any aditional testing needed (new WAF Rules, SG configuration, etc)

### Notes
The Global Accelerator will only work when Flag `Enabled` is set `true`, to be able to deploy and destroy this flag must be defined as `false`.
