class Recipe < ApplicationRecord
  belongs_to :chef
  has_many :steps
  accepts_nested_attributes_for :steps

  has_rich_text :description

  scope :first_per_chef, -> {
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :asc)
  }

  scope :latest_per_chef, -> {
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :desc)
  }

  scope :per_chef, -> {
    group(:chef_id).count
  }

  scope :with_description, ->(string = "") {
    joins(:rich_text_description).where("body LIKE ?", "%#{string}%")
  }

  scope :by_duration, -> {
    joins(:steps).group(:id).sum(:duration)
  }

  scope :quick, -> {
    joins(:steps).group(:id).having("SUM(duration) <= ?", 15.minutes.iso8601)
  }
end
