You will need a personal AWS account. There is no EBRC organization
account at this time. Per best practices, use
[IAM](https://aws.amazon.com/iam/) to manage a restricted user for
Packer to do its thing.

Create a IAM User named `packer` (the specific name is not important).

Create a IAM Group named `packer_ami_builder`(the specific name is not
important).

Create a Policy named `PackerAMI` (the specific name is not important).

The following policy is based on [IAM policy for
Packer](https://www.packer.io/docs/builders/amazon.html) with added
`ec2:*Spot*` actions so Spot instances can be used for the build.

Assign the policy to the IAM group (`packer_ami_builder`) and assign
that group to the IAM user Packer will use (`packer`). .

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelSpotInstanceRequests",
                "ec2:CopyImage",
                "ec2:CreateImage",
                "ec2:CreateKeypair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateSpotDatafeedSubscription",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteKeypair",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteSpotDatafeedSubscription",
                "ec2:DeleteVolume",
                "ec2:DeregisterImage",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeRegions",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSpotDatafeedSubscription",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "ec2:GetPasswordData",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:RegisterImage",
                "ec2:RequestSpotInstances",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances"
            ],
            "Resource": "*"
        }
    ]
}
```
[IAM Groups page](https://console.aws.amazon.com/iam/home#/groups) create
a `packer_ami_builder` group (the specific name is not important).
