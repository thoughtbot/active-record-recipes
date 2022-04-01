# Query for Recipe by Duration

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  has_many :steps

  scope :by_duration, -> {
    joins(:steps)
      .group(:name)
      .order("SUM(steps.duration) ASC")
      .sum(:duration)
  }

  scope :quick, -> {
    joins(:steps).group(:id).having("SUM(duration) <= ?", 15.minutes.iso8601)
  }
end
```

```ruby
Recipe.by_duration
# => {"Recipe Two"=>5 minutes, "Recipe One"=>25 minutes}
Recipe.quick
# => [#<Recipe>, #<Recipe>]
```