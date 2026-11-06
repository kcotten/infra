locals {
  rendered_tags = join(", ", [for key, value in var.tags : "${key}=${value}"])
}

resource "random_pet" "suffix" {
  length = 2
}

resource "local_file" "greeting" {
  filename = "${var.directory}/${var.name}-${random_pet.suffix.id}.txt"
  content  = "${var.message}, ${var.name}! (${random_pet.suffix.id})\nTags: ${local.rendered_tags}\n"

  # The provider default is 0777, which would make every file world-writable.
  file_permission      = "0644"
  directory_permission = "0755"
}
