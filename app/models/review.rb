class Review < ApplicationRecord
  belongs_to :recipe
  validates :rating, numericality: {only_integer: true, in: 0..5}
end
