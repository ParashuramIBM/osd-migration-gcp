variable "notification_channels" {
  type    = list(string)
  default = []
  description = "List of notification channel IDs to send alerts to"
}