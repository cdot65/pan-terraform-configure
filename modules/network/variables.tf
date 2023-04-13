/* Security Zones --------------------------------------------------------- */

variable "wan_zone_name" {
  description = "name of our WAN zone"
}

variable "wan_zone_mode" {
  description = "WAN zone mode"
}

variable "dmz_zone_name" {
  description = "name of our DMZ zone"
}

variable "dmz_zone_mode" {
  description = "DMZ zone mode"
}

/* Network Interfaces ----------------------------------------------------- */

variable "eth_interfaces" {
  description = "List of Ethernet interfaces"
  type = list(object({
    name          = string
    mode          = string
    vsys          = string
    dhcp          = bool
    default_route = bool
    ips           = list(string)
  }))
}

/* Virtual Router --------------------------------------------------------- */

variable "vr_name" {
  description = "Virtual Router name"
}
