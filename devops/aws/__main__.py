"""An AWS Python Pulumi program"""

import pulumi
import pulumi_aws as aws


eks_vpc = aws.ec2.Vpc("e621RisingEksVpc", cidr_block="10.0.0.0/16")

default_availability_zones = aws.get_availability_zones()
eks_vpc_subnet_1 = aws.ec2.Subnet("e621RisingEksVpcSubnet1", cidr_block="10.0.3.0/24", vpc_id=eks_vpc.id, availability_zone=default_availability_zones.names[0])
eks_vpc_subnet_2 = aws.ec2.Subnet("e621RisingEksVpcSubnet2", cidr_block="10.0.2.0/24", vpc_id=eks_vpc.id, availability_zone=default_availability_zones.names[1])

eks_cluster_assume_role = aws.iam.get_policy_document(statements=[aws.iam.GetPolicyDocumentStatementArgs(
    effect="Allow",
    principals=[aws.iam.GetPolicyDocumentStatementPrincipalArgs(
        type="Service",
        identifiers=["eks.amazonaws.com"],
    )],
    actions=["sts:AssumeRole"],
)])

eks_cluster_role = aws.iam.Role("e621RisingEksClusterRole", assume_role_policy=eks_cluster_assume_role.json)

eks_cluster_policy = aws.iam.RolePolicyAttachment(
    "e621RisingEksAmazonEKSClusterPolicy",
    policy_arn="arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    role=eks_cluster_role.name
)

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
eksvpc_resource_controller = aws.iam.RolePolicyAttachment(
    "e621RisingEksAmazonEKSVPCResourceController",
    policy_arn="arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    role=eks_cluster_role.name
)

eks_cluster = aws.eks.Cluster(
    "e621RisingEksCluster",
    role_arn=eks_cluster_role.arn,
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

eks_worker_assume_role = aws.iam.get_policy_document(statements=[aws.iam.GetPolicyDocumentStatementArgs(
    effect="Allow",
    principals=[aws.iam.GetPolicyDocumentStatementPrincipalArgs(
        type="Service",
        identifiers=["ec2.amazonaws.com"],
    )],
    actions=["sts:AssumeRole"],
)])

eks_worker_role = aws.iam.Role("e621RisingEksWorkerRole", assume_role_policy=eks_worker_assume_role.json)

eks_worker_role_policy_attachment = aws.iam.RolePolicyAttachment(
    'e621RisingEksWorkerRolePolicyAttachmentWorkerNodePolicy',
    role=eks_worker_role.name,
    policy_arn='arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy'
)

eks_worker_role_policy_attachment2 = aws.iam.RolePolicyAttachment(
    'e621RisingEksWorkerRolePolicyAttachmentEc2ContainerRegistryReadOnly',
    role=eks_worker_role.name,
    policy_arn='arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly'
)

arm_node_group = aws.eks.NodeGroup(
    "e621RisingEksArmNodeGroup",
    cluster_name=eks_cluster.name,
    node_role_arn=eks_worker_role.arn,
    ami_type='AL2_ARM_64',
    subnet_ids=[eks_vpc_subnet_1.id, eks_vpc_subnet_2.id],
    instance_types=["r6g.xlarge"],
    scaling_config=aws.eks.NodeGroupScalingConfigArgs(desired_size=0, max_size=3, min_size=0),
    opts=pulumi.ResourceOptions(depends_on=[
        eks_worker_role_policy_attachment,
        eks_worker_role_policy_attachment2,
    ])
)

x86_node_group = aws.eks.NodeGroup(
    "e621RisingEksX86NodeGroup",
    cluster_name=eks_cluster.name,
    node_role_arn=eks_worker_role.arn,
    ami_type='AL2_x86_64',
    subnet_ids=[eks_vpc_subnet_1.id, eks_vpc_subnet_2.id],
    instance_types=["r6i.xlarge"],
    scaling_config=aws.eks.NodeGroupScalingConfigArgs(desired_size=0, max_size=3, min_size=0),
    opts=pulumi.ResourceOptions(depends_on=[
        eks_worker_role_policy_attachment,
        eks_worker_role_policy_attachment2,
    ])
)

pulumi.export("endpoint", eks_cluster.endpoint)
pulumi.export("kubeconfig-certificate-authority-data", eks_cluster.certificate_authority.data)
