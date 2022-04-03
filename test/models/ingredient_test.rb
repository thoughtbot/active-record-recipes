require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "should be valid" do
    ingredient = Ingredient.new

    assert ingredient.valid?
  end

  test "should downcase name" do
    ingredient = Ingredient.new(name: "UPPERCASE")
    ingredient.save!

    assert_equal "uppercase", ingredient.name
  end

  test "name should be unique" do
    Ingredient.create!(name: "NAME")
    ingredient = Ingredient.new(name: "name")

    assert_not ingredient.valid?
  end

  test "#measurements" do
    ingredient = Ingredient.create!
    chef = Chef.create!(name: "Name")
    recipe = chef.recipes.create!(name: "Recipe", servings: 1)

    assert_difference("Measurement.count", 1) do
      ingredient.measurements.create!(recipe: recipe)
    end

    assert_no_difference("Measurement.count") do
      ingredient.destroy
    end
  end

  test ".popular" do
    chef = Chef.create!(name: "Name")
    sugar = Ingredient.create!(name: "Sugar")
    egg = Ingredient.create!(name: "Egg")
    flour = Ingredient.create!(name: "Flour")
    recipe_one = chef.recipes.create!(name: "Recipe with Sugar", servings: 1)
    recipe_two = chef.recipes.create!(name: "Recipe With Egg", servings: 1)
    recipe_three = chef.recipes.create!(name: "Recipe With Flour", servings: 1)
    recipe_four = chef.recipes.create!(name: "Recipe with Sugar and Egg", servings: 1)
    recipe_one.measurements.create!(ingredient: sugar)
    recipe_two.measurements.create!(ingredient: egg)
    recipe_three.measurements.create!(ingredient: flour)
    recipe_four.measurements.create!(ingredient: sugar)
    recipe_four.measurements.create!(ingredient: egg)

    assert_equal({"egg" => 2, "sugar" => 2, "flour" => 1}, Ingredient.popular)
  end
end
