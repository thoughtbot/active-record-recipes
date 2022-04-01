# Group Chefs by number of Recipes

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef

  def self.per_chef
    Chef
      .joins(:recipes)
      .group(:name)
      .order("COUNT(recipes.chef_id) DESC, chefs.name ASC")
      .count
  end
end
```

```ruby
Recipe.per_chef
# => {"Bob" => 2, "Ali" => 1, "Alice" => 1}
```