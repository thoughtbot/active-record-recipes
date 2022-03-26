# Query for Chefs with Unhealthy Recipes

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef
  has_many :measurements, dependent: :destroy
  has_many :ingredients, through: :measurements

  validates :servings, presence: true

  scope :unhealthy, -> {
    joins(:ingredients)
      .where({ingredients: {name: "sugar"}})
      .group(:id)
      .having("(SUM(grams) / recipes.servings) >= ?", 20.00)
  }
end
```

```ruby
# app/models/chef.rb
class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :unhealthy_recipes, -> { unhealthy }, class_name: "Recipe"

  scope :with_unhealthy_recipes, -> {
    joins(:unhealthy_recipes).distinct
  }
end
```

```ruby
Chef.with_unhealthy_recipes
# => [#<Chef>, #<Chef>]
Chef.first.unhealthy_recipes
# => [#<Recipe>, #<Recipe>]
```