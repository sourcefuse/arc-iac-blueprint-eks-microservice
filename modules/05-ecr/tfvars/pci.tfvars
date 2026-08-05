# PCI DSS profile controls:
#   - image_tag_mutability = IMMUTABLE enforces immutable image tags so audited
#     builds cannot be silently replaced (change-control / integrity).
#   - encryption_type = KMS provides KMS-managed encryption of images at rest,
#     the tightest at-rest protection this module supports.
namespace          = "eb"
environment        = "prod"
compliance_profile = "pci_dss"

image_tag_mutability = "IMMUTABLE"
encryption_type      = "KMS"
