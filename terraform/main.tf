terraform {
  required_version = ">= 0.12.0"
}

variable "first_name" {
  description = "first name"
}

variable "last_name" {
  description = "last name"
}

variable "email" {
  description = "email"
}

variable "phone" {
  description = "phone"
}

variable "card_number" {
  description = "credit card number"
}

variable "card_cvv" {
  description = "cvv"
}

variable "card_expiration_date" {
  description = "expiration date"
}

variable "card_zip_code" {
  description = "zip code"
}

variable "store_street" {
  description = "store street"
}

variable "store_city" {
  description = "store city"
}

variable "store_state" {
  description = "store state"
}

variable "store_zip_code" {
  description = "store zip code"
}

variable "pizza1_attributes" {
  description = "attributes of the first pizza to order"
  type        = list(string)
}

variable "pizza1_quantity" {
  description = "number of the first pizza to order"
  type        = number
}

variable "pizza2_attributes" {
  description = "attributes of the second pizza to order"
  type        = list(string)
}

variable "pizza2_quantity" {
  description = "number of the second pizza to order"
  type        = number
}

variable "pizza3_attributes" {
  description = "attributes of the third pizza to order"
  type        = list(string)
}

variable "pizza3_quantity" {
  description = "number of the third pizza to order"
  type        = number
}

variable "drink_attributes" {
  description = "attributes of the drink to order"
  type        = list(string)
}

variable "drink_quantity" {
  description = "number of the drink to order"
  type        = number
}

provider "dominos" {
  first_name    = var.first_name
  last_name     = var.last_name
  email_address = var.email
  phone_number  = var.phone

  credit_card {
    number = var.card_number
    cvv    = var.card_cvv
    date   = var.card_expiration_date
    zip    = var.card_zip_code
  }
}

data "dominos_address" "addr" {
  street = var.store_street
  city   = var.store_city
  state  = var.store_state
  zip    = var.store_zip_code
}

data "dominos_store" "store" {
  address_url_object = data.dominos_address.addr.url_object
}

data "dominos_menu_item" "pizza1" {
  store_id     = data.dominos_store.store.store_id
  query_string = var.pizza1_attributes
}

data "dominos_menu_item" "pizza2" {
  store_id     = data.dominos_store.store.store_id
  query_string = var.pizza2_attributes
}

# data "dominos_menu_item" "pizza3" {
#   store_id     = data.dominos_store.store.store_id
#   query_string = var.pizza3_attributes
# }

data "dominos_menu_item" "drink" {
  store_id     = data.dominos_store.store.store_id
  query_string = var.drink_attributes
}

locals {
  pizza1_list = flatten([
    for item in range(var.pizza1_quantity) :
    data.dominos_menu_item.pizza1[*].matches[0].code
  ])
  pizza2_list = flatten([
    for item in range(var.pizza2_quantity) :
    data.dominos_menu_item.pizza2[*].matches[0].code
  ])
  # pizza3_list = flatten([
  #   for item in range(var.pizza3_quantity) :
  #   data.dominos_menu_item.pizza3[*].matches[0].code
  # ])
  drink_list = flatten([
    for item in range(var.drink_quantity) :
    data.dominos_menu_item.drink[*].matches[0].code
  ])
}

resource "dominos_order" "order" {
  address_api_object = data.dominos_address.addr.api_object
  item_codes         = flatten([local.pizza1_list, local.pizza2_list, local.drink_list])
  #item_codes         = flatten([local.pizza1_list, local.drink_list])
  store_id           = data.dominos_store.store.store_id
}

# output "pizza1" {
#   value = [
#     for pizza in data.dominos_menu_item.pizza1[*]:
#       {
#         name = pizza.matches[0].name
#         code = pizza.matches[0].code
#         price_cents = pizza.matches[0].price_cents
#       }
#   ]
# }

# output "pizza2" {
#   value = [
#     for pizza in data.dominos_menu_item.pizza2[*]:
#       {
#         name = pizza.matches[0].name
#         code = pizza.matches[0].code
#         price_cents = pizza.matches[0].price_cents
#       }
#   ]
# }

# output "pizza3" {
#   value = [
#     for pizza in data.dominos_menu_item.pizza3[*]:
#       {
#         name = pizza.matches[0].name
#         code = pizza.matches[0].code
#         price_cents = pizza.matches[0].price_cents
#       }
#   ]
# }

# output "drinks" {
#   value = [
#     for drink in data.dominos_menu_item.drink:
#       {
#         name = drink.matches[0].name
#         code = drink.matches[0].code
#         price_cents = drink.matches[0].price_cents
#       }
#   ]
# }
