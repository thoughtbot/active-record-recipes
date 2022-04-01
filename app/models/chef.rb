class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :unhealthy_recipes, -> { unhealthy }, class_name: "Recipe"
  has_many :quick_recipes, -> { quick }, class_name: "Recipe"

  has_one :first_recipe, -> { order(created_at: :asc) }, class_name: "Recipe"
  has_one :latest_recipe, class_name: "Recipe"

  scope :with_unhealthy_recipes, -> {
    joins(:recipes)
      .where(recipes: Recipe.unhealthy)
      .order(:name)
      .distinct
  }

  scope :with_quick_recipes, -> {
    joins(:recipes)
      .where(recipes: Recipe.quick)
      .order(:name)
      .distinct
  }

  scope :with_recipes_with_ingredients, ->(ingredients) {
    joins(recipes: :ingredients)
      .where({ingredients: {name: ingredients}})
      .distinct
      .order(:name)
  }
end
