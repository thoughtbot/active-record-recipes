# Query for Chef by Recipe by Rating

```ruby
# app/models/chef.rb
class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy

  def self.with_recipes_with_average_rating_above(rating)
    joins(recipes: :reviews)
      .where(recipes: Recipe.with_average_rating_above(rating))
      .distinct
      .order(:name)
  end
end
```

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef
  has_many :reviews, dependent: :destroy

  validates :name, uniqueness: {scope: :chef}

  def self.with_average_rating_above(rating)
    joins(:reviews)
      .group(:id)
      .having("AVG(reviews.rating) > ?", rating)
      .order("AVG(reviews.rating) DESC")
  end
end
```

```ruby
Chef.with_average_rating_above(4.4)
# => [#<Chef>, #<Chef>]
```