namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

kubernetes_version  = "1.36"

# Compute model: false = managed node groups (below); true = EKS Auto Mode.
# Auto Mode ON: AWS provisions/scales nodes (built-in Karpenter). 05-eks-addon
# then auto-disables the overlapping add-ons (LB Controller, EBS CSI, Cluster
# Autoscaler) and instead installs the Auto Mode primitives (ALB IngressClass ->
# eks.amazonaws.com/alb, gp3 default StorageClass, a Karpenter NodePool +
# NodeClass). The managed node-group settings below are ignored while this is true.
#
# auto_mode_node_pools keeps the built-in "general-purpose" + "system" pools on
# (guarantees nodes). The custom NodePool from 05 runs alongside them. For pure
# production parity (custom NodePool only), set auto_mode_node_pools = [].
enable_auto_mode    = true
node_instance_types = ["t3.large"]
node_desired_size   = 2
node_min_size       = 2
node_max_size       = 5
