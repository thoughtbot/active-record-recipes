class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :sweet_recipes, -> { sweet }, class_name: "Recipe"
  has_many :quick_recipes, -> { quick }, class_name: "Recipe"

  has_one :first_recipe, -> { order(created_at: :asc) }, class_name: "Recipe"
  has_one :latest_recipe, class_name: "Recipe"

  validates :name, presence: true
  validates :name, uniqueness: true

  scope :with_sweet_recipes, -> {
    joins(recipes: [ingredients: :measurements])
      .where(recipes: Recipe.sweet)
      .order(:name)
      .distinct
  }

  scope :with_quick_recipes, -> {
    joins(recipes: :steps)
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

  scope :with_recipes_with_average_rating_above, ->(rating) {
    joins(recipes: :reviews)
      .where(recipes: Recipe.with_average_rating_above(rating))
      .distinct
      .order(:name)
  }
end
