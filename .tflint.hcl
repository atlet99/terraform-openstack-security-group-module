# tflint configuration
# Rules reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/main/docs/rules/README.md

plugin "terraform" {
  enabled = true
  preset  = "all"
}

###############################################################################
# Recommended rules (enabled by preset, listed for visibility)
###############################################################################

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_lookup" {
  enabled = true
}

rule "terraform_empty_list_equality" {
  enabled = true
}

rule "terraform_json_syntax" {
  enabled = true
}

rule "terraform_map_duplicate_keys" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_module_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = true
}

###############################################################################
# Non-recommended rules (explicitly enabled)
###############################################################################

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_shallow_clone" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true

  variable {
    format = "snake_case"
  }

  locals {
    format = "snake_case"
  }

  output {
    format = "snake_case"
  }

  resource {
    format = "snake_case"
  }

  data {
    format = "snake_case"
  }

  module {
    format = "snake_case"
  }
}

rule "terraform_standard_module_structure" {
  enabled = false
}

rule "terraform_unused_required_providers" {
  enabled = true
}
