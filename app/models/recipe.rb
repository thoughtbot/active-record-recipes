class Recipe < ApplicationRecord
  belongs_to :chef
  has_rich_text :description

  scope :first_per_chef, -> {
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :asc)
  }

  scope :latest_per_chef, -> {
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :desc)
  }
end
