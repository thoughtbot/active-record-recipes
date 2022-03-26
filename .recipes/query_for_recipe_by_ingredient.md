# Query for Recipe by Ingredient

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  has_many :measurements, dependent: :destroy
  has_many :ingredients, through: :measurements

  validates :servings, presence: true

  scope :unhealthy, -> {
    joins(:ingredients)
      .where({ingredients: {name: "sugar"}})
      .group(:id)
      .having("(SUM(grams) / recipes.servings) >= ?", 20.00)
  }

  scope :with_ingredients, ->(ingredients) {
    joins(:ingredients)
      .where({ingredients: {name: ingredients}})
      .order(:name)
      .distinct
  }
end
```

```ruby
Recipe.unhealthy
# => [#<Recipe>, #<Recipe>]
Recipe.with_ingredients(["sugar", "flower"])
# => [#<Recipe>, #<Recipe>]
```