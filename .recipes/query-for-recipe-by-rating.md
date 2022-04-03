# Query for Recipe by Rating

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

  def self.by_average_rating
    joins(:reviews, :chef)
      .group("recipes.name", "chefs.name")
      .order("AVG(reviews.rating) DESC, recipes.name ASC")
      .average(:rating)
  end
end
```

```ruby
Recipe.by_average_rating
# =>  {
# =>    ["Highly Rated Recipe", "Chef Two"] => 5,
# =>    ["Highly Rated Recipe", "Chef One"] => 4.5,
# =>    ["Poorly Rated Recipe", "Chef One"] => 1.5
# =>  }

Recipe.with_average_rating_above(4.4)
# => [#<Recipe>, #<Recipe>]
```