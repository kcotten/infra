# Run with: terraform -chdir=modules/greeting test

variables {
  name      = "tester"
  directory = "./test-output"
  tags = {
    Owner = "kris"
  }
}

run "writes_a_greeting_with_tags" {
  command = apply

  assert {
    condition     = strcontains(local_file.greeting.content, "Hello, tester!")
    error_message = "Greeting should address the name given."
  }

  assert {
    condition     = strcontains(local_file.greeting.content, "Owner=kris")
    error_message = "Greeting should record the tags given."
  }

  assert {
    condition     = local_file.greeting.file_permission == "0644"
    error_message = "Greeting files should not be world-writable."
  }

  assert {
    condition     = startswith(output.file_path, "./test-output/tester-")
    error_message = "File should be written into the requested directory, named after the greeting."
  }
}

run "rejects_an_upper_case_name" {
  command = plan

  variables {
    name = "Not-Valid"
  }

  expect_failures = [var.name]
}

run "rejects_a_blank_message" {
  command = plan

  variables {
    message = "   "
  }

  expect_failures = [var.message]
}
