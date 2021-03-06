class Recipe < ApplicationRecord
  belongs_to :chef
  has_many :steps
  has_many :measurements, dependent: :destroy
  has_many :ingredients, through: :measurements
  has_many :reviews, dependent: :destroy
  accepts_nested_attributes_for :steps

  has_rich_text :description

  validates :name, :servings, presence: true
  validates :name, uniqueness: {scope: :chef}

  def self.first_per_chef
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :asc)
  end

  def self.latest_per_chef
    select("DISTINCT ON(recipes.chef_id) recipes.*")
      .order(:chef_id, created_at: :desc)
  end

  def self.with_description_containing(string)
    joins(:rich_text_description)
      .where(
        "body LIKE ?",
        "%" + Recipe.sanitize_sql_like(string) + "%"
      )
  end

  def self.quick
    joins(:steps).group(:id).having("SUM(duration) <= ?", 15.minutes.iso8601)
  end

  def self.sweet
    joins(ingredients: :measurements)
      .where({ingredients: {name: "sugar"}})
      .group(:id)
      .having(
        "(SUM(DISTINCT measurements.grams) / recipes.servings) >= ?", 20.00
      )
  end

  def self.with_ingredients(ingredients)
    joins(:ingredients)
      .where({ingredients: {name: ingredients}})
      .order(:name)
      .distinct
  end

  def self.with_average_rating_above(rating)
    joins(:reviews)
      .group(:id)
      .having("AVG(reviews.rating) > ?", rating)
      .order("AVG(reviews.rating) DESC")
  end

  def self.by_duration
    joins(:steps)
      .group(:name, :chef_id)
      .order("SUM(steps.duration) ASC")
      .sum(:duration)
  end

  def self.per_chef
    Chef
      .joins(:recipes)
      .group(:name)
      .order("COUNT(recipes.chef_id) DESC, chefs.name ASC")
      .count
  end

  def self.by_average_rating
    joins(:reviews, :chef)
      .group("recipes.name", "chefs.name")
      .order("AVG(reviews.rating) DESC, recipes.name ASC")
      .average(:rating)
  end
end
