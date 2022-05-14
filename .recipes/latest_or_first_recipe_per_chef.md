# Latest (or first) Recipe per Chef

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef

  def self.first_per_chef
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :asc)
  end

  def self.latest_per_chef
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :desc)
  end
end
```

```ruby
Recipe.first_per_chef
# => [#<Recipe>, #<Recipe>]
Recipe.latest_per_chef
# => [#<Recipe>, #<Recipe>]
```

```ruby
# app/models/chef.rb
class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy

  has_one :first_recipe, -> { order(created_at: :asc) }, class_name: "Recipe"
  has_one :latest_recipe, class_name: "Recipe"
end
```

```ruby
Chef.first_recipe
# => #<Recipe>
Chef.latest_recipe
# => #<Recipe>
```
