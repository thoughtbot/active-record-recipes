# Query Recipes by Action Text Body

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  has_rich_text :description

  scope :with_description, ->(string = "") {
    joins(:rich_text_description).where("body LIKE ?", "%#{string}%")
  }
end
```