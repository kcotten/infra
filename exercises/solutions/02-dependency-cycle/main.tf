locals {
  primary_path = "${path.module}/output/primary.txt"
  backup_path  = "${path.module}/output/backup.txt"
}

resource "local_file" "primary" {
  filename = local.primary_path
  content  = "A backup of this file lives at ${local.backup_path}\n"
}

resource "local_file" "backup" {
  filename = local.backup_path
  content  = "Backup of the file with checksum ${local_file.primary.content_md5}\n"
}
