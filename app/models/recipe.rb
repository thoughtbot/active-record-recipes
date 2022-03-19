class Recipe < ApplicationRecord
  belongs_to :chef
  has_rich_text :description
end
