# Group Chefs by number of Recipes

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef

  scope :per_chef, -> {
    group(:chef_id).count
  }
end
```

```ruby
Recipe.per_chef
# => {1 => 20, 2 => 6}
```