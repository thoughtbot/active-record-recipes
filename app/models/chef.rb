class Chef < ApplicationRecord
  has_many :recipes, dependent: :destroy
end
