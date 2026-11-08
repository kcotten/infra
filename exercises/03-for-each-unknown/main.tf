# refactor to use for_each
locals {
  teams = toset(["red", "green", "blue"])
}

resource "random_pet" "team" {
  for_each = local.teams
  length   = 1
}

resource "local_file" "badge" {
  for_each = random_pet.team

  filename = "${path.module}/output/${each.key}.txt"
  content  = "Badge for ${each.key}\n"
}
