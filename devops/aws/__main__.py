"""An AWS Python Pulumi program"""

import pulumi
import pulumi_aws as aws


eks_vpc = aws.ec2.Vpc("e621RisingEksVpc", cidr_block="10.0.0.0/16")

default_availability_zones = aws.get_availability_zones()
eks_vpc_subnet_1 = aws.ec2.Subnet("e621RisingEksVpcSubnet1", cidr_block="10.0.3.0/24", vpc_id=eks_vpc.id, availability_zone=default_availability_zones.names[0])
eks_vpc_subnet_2 = aws.ec2.Subnet("e621RisingEksVpcSubnet2", cidr_block="10.0.2.0/24", vpc_id=eks_vpc.id, availability_zone=default_availability_zones.names[1])

eks_assume_role = aws.iam.get_policy_document(statements=[aws.iam.GetPolicyDocumentStatementArgs(
    effect="Allow",
    principals=[aws.iam.GetPolicyDocumentStatementPrincipalArgs(
        type="Service",
        identifiers=["eks.amazonaws.com"],
    )],
    actions=["sts:AssumeRole"],
)])

eks_role = aws.iam.Role("e621RisingEksRole", assume_role_policy=eks_assume_role.json)

eks_cluster_policy = aws.iam.RolePolicyAttachment(
    "e621RisingEksAmazonEKSClusterPolicy",
    policy_arn="arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    role=eks_role.name
)

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
eksvpc_resource_controller = aws.iam.RolePolicyAttachment(
    "e621RisingEksAmazonEKSVPCResourceController",
    policy_arn="arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    role=eks_role.name
)

eks_cluster = aws.eks.Cluster(
    "e621RisingEksCluster",
    role_arn=eks_role.arn,
    vpc_config=aws.eks.ClusterVpcConfigArgs(
        subnet_ids=[
            eks_vpc_subnet_1.id,
            eks_vpc_subnet_2.id
        ],
    ),
    opts=pulumi.ResourceOptions(depends_on=[
        eks_cluster_policy,
        eksvpc_resource_controller,
    ])
)

pulumi.export("endpoint", eks_cluster.endpoint)
pulumi.export("kubeconfig-certificate-authority-data", eks_cluster.certificate_authority.data)
