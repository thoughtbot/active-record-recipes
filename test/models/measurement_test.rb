require "test_helper"

class MeasurementTest < ActiveSupport::TestCase
  test "should be valid" do
    ingredient = Ingredient.create!
    chef = Chef.create!(name: "Name")
    recipe = chef.recipes.create!(name: "Recipe", servings: 1)
    measurement = ingredient.measurements.new(recipe: recipe)

    assert measurement.valid?
  end
end
