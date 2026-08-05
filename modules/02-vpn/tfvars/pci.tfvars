# =============================================================================
# 02-vpn - PCI DSS Compliance Profile
# =============================================================================
# Client VPN for operator access to the private VPC. The client address pool is
# auto-derived from the VPC CIDR (see main.tf), so nothing to set here beyond the
# standard identifiers.
# =============================================================================

namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"
