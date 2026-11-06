resource "local_file" "primary" {
  filename = "${path.module}/output/primary.txt"
  content  = "A backup of this file lives at ${local_file.backup.filename}\n"
}

resource "local_file" "backup" {
  filename = "${path.module}/output/backup.txt"
  content  = "Backup of the file with checksum ${local_file.primary.content_md5}\n"
}
