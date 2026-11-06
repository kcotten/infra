module "namer" {
  source = "./modules/namer"
}

resource "local_file" "name_tag" {
  filename = "${path.module}/output/name.txt"
  content  = "Name: ${module.namer.name}\n"
}
