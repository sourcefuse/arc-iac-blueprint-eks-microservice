namespace          = "eb"
environment        = "dev"
compliance_profile = "general"

kubernetes_version  = "1.36"

# Compute model: false = managed node groups (below); true = EKS Auto Mode.
enable_auto_mode    = false
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 10
