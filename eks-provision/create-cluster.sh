aws eks create-cluster \
    --name lance-eks-demo \
    --role-arn arn:aws:iam::338430314199:role/lance-eks-demo \
    --resources-vpc-config subnetIds=subnet-0697703a5cee1c763,subnet-0b05c599aa75267e8,subnet-07940df2f00a4b15b,securityGroupIds=sg-06eec9099dac1520d
