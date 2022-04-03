# Query for Chef by Recipe by Rating

```ruby
# app/models/chef.rb
class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy

  scope :with_recipes_with_average_rating_above, ->(rating) {
    joins(recipes: :reviews)
      .where(recipes: Recipe.with_average_rating_above(rating))
      .distinct
      .order(:name)
  }
end
```

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  belongs_to :chef
  has_many :reviews, dependent: :destroy

  validates :name, uniqueness: {scope: :chef}

  scope :with_average_rating_above, ->(rating) {
    joins(:reviews)
      .group(:id)
      .having("AVG(reviews.rating) > ?", rating)
      .order("AVG(reviews.rating) DESC")
  }
end
```

```ruby
Chef.with_average_rating_above(4.4)
# => [#<Chef>, #<Chef>]
```