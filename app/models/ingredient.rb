class Ingredient < ApplicationRecord
  has_many :measurements, dependent: :restrict_with_error

  validates :name, uniqueness: true
  before_validation :downcase_name

  def self.popular
    joins(:measurements)
      .group(:name)
      .order("COUNT(measurements.id) DESC, ingredients.name ASC")
      .count
  end

  private

  def downcase_name
    if name
      self.name = name.downcase
    end
  end
end
