resource "random_pet" "mascot" {
  length = 2

resource "local_file" "mascot_note" {
  filename = "${path.module}/output/mascot.txt"
  content  = "Our mascot is ${random_pet.mascot.id}\n"
}
