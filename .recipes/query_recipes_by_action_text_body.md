# Query Recipes by Action Text Body

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  has_rich_text :description

  def self.with_description_containing(string)
    joins(:rich_text_description)
      .where(
        "body LIKE ?",
        "%" + Recipe.sanitize_sql_like(string) + "%"
      )
  end
end
```

```ruby
Recipe.with_description_containing("hello")
# => [#<Recipe>, #<Recipe>]
```