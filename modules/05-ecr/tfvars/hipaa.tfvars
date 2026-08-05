# HIPAA profile controls:
#   - image_tag_mutability = IMMUTABLE prevents tag overwrites so a deployed
#     image digest can always be traced back to its source (integrity control).
#   - encryption_type = KMS encrypts images at rest with KMS rather than the
#     default AES256, satisfying stricter key-management requirements.
namespace          = "eb"
environment        = "prod"
compliance_profile = "hipaa"

image_tag_mutability = "IMMUTABLE"
encryption_type      = "KMS"
