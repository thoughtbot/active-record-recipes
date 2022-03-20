class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy

  has_one :first_recipe, -> { order(created_at: :asc) }, class_name: "Recipe"
  has_one :latest_recipe, class_name: "Recipe"
end
