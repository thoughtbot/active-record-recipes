# Query for Chefs by Recipe Duration

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef
  has_many :steps

  scope :quick, -> {
    joins(:steps).group(:id).having("SUM(duration) <= ?", 15.minutes.iso8601)
  }
end
```

```ruby
# app/models/chef.rb
class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :quick_recipes, -> { quick }, class_name: "Recipe"

  scope :with_quick_recipes, -> {
    joins(recipes: :steps)
      .where(recipes: Recipe.quick)
      .order(:name)
      .distinct
  }
end

```

```ruby
Chef.with_quick_recipes
# => [#<Chef>, #<Chef>]
Chef.first.quick_recipes
# => [#<Recipe>, #<Recipe>]
```