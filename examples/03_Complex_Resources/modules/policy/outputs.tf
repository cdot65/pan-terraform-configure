output "example_security_policy" {
  value = panos_security_policy.security_policies["dmz_to_wan"].id
}
