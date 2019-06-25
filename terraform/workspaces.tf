terraform {
  backend "azurerm" {
    storage_account_name = "terraformvolkulion"
    container_name       = "terraform"
    key                  = "dev.terraform.tera"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    access_key = "07fdWOaYDuW4t0tzKzjDA2kGtc7cFAV0xcgPgM3nu/peq8L96Lr9p//63txkQbeGZlDgYvf+HOf+Sq0QMkhbXg==/2+xGJw7Oe6f+rC2B4oqXg=="
  }
}