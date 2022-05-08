# Query for Chefs by Recipe Ingredient

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef
  has_many :measurements, dependent: :destroy
  has_many :ingredients, through: :measurements

  validates :servings, presence: true

  scope :sweet, -> {
    joins(ingredients: :measurements)
      .where({ingredients: {name: "sugar"}})
      .group(:id)
      .having(
        "(SUM(DISTINCT measurements.grams) / recipes.servings) >= ?", 20.00
      )
  }
end
```

```ruby
# app/models/chef.rb
class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :sweet_recipes, -> { sweet }, class_name: "Recipe"

  scope :with_sweet_recipes, -> {
    joins(recipes: [ingredients: :measurements])
      .where(recipes: Recipe.sweet)
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
```

```ruby
Chef.with_sweet_recipes
# => [#<Chef>, #<Chef>]
Chef.first.sweet_recipes
# => [#<Recipe>, #<Recipe>]
Chef.with_recipes_with_ingredients(["sugar", "egg"])
# => [#<Chef>, #<Chef>]
```