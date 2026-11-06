resource "random_pet" "team" {
  count  = 3
  length = 1
}

resource "local_file" "badge" {
  for_each = toset(random_pet.team[*].id)

  filename = "${path.module}/output/${each.key}.txt"
  content  = "Badge for ${each.key}\n"
}
