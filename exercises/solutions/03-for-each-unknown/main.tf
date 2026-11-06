resource "random_pet" "team" {
  count  = 3
  length = 1
}

# Keys must be known at plan time; values may be unknown until apply.
resource "local_file" "badge" {
  for_each = { for index, pet in random_pet.team : "member-${index}" => pet.id }

  filename = "${path.module}/output/${each.key}.txt"
  content  = "Badge for ${each.value}\n"
}
