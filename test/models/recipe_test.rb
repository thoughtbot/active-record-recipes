require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "should be valid" do
    chef = Chef.create!
    recipe = chef.recipes.new(servings: 1)

    assert recipe.valid?
  end

  test "#ingredients" do
    ingredient = Ingredient.create!
    chef = Chef.create!
    recipe = chef.recipes.create!(servings: 1)
    ingredient.measurements.create!(recipe: recipe)

    assert_includes recipe.ingredients, ingredient
  end

  test "#measurements" do
    ingredient = Ingredient.create!
    chef = Chef.create!
    recipe = chef.recipes.create!(servings: 1)

    assert_difference("Measurement.count", 1) do
      ingredient.measurements.create!(recipe: recipe)
    end

    assert_difference("Measurement.count", -1) do
      recipe.destroy
    end
  end

  test "#description" do
    chef = Chef.create!

    assert_difference("ActionText::RichText.count", 1) do
      chef.recipes.create!(description: "some description", servings: 1)
    end
  end

  test ".latest_per_chef" do
    chef_one = Chef.create!
    chef_two = Chef.create!
    chef_one.recipes.create!(name: "Latest Recipe For Chef One", servings: 1, created_at: 1.hour.ago)
    chef_one.recipes.create!(name: "First Recipe For Chef One", servings: 1, created_at: 1.day.ago)
    chef_two.recipes.create!(name: "Latest Recipe For Chef Two", servings: 1, created_at: 1.hour.ago)
    chef_two.recipes.create!(name: "First Recipe For Chef Two", servings: 1, created_at: 1.day.ago)

    assert_equal ["Latest Recipe For Chef One", "Latest Recipe For Chef Two"], Recipe.latest_per_chef.map(&:name)
  end

  test ".first_per_chef" do
    chef_one = Chef.create!
    chef_two = Chef.create!
    chef_one.recipes.create!(name: "Latest Recipe For Chef One", servings: 1, created_at: 1.hour.ago)
    chef_one.recipes.create!(name: "First Recipe For Chef One", servings: 1, created_at: 1.day.ago)
    chef_two.recipes.create!(name: "Latest Recipe For Chef Two", servings: 1, created_at: 1.hour.ago)
    chef_two.recipes.create!(name: "First Recipe For Chef Two", servings: 1, created_at: 1.day.ago)

    assert_equal ["First Recipe For Chef One", "First Recipe For Chef Two"], Recipe.first_per_chef.map(&:name)
  end

  test ".per_chef" do
    chef_one = Chef.create!(name: "Bob")
    chef_two = Chef.create!(name: "Alice")
    chef_three = Chef.create!(name: "Ali")
    chef_one.recipes.create!(servings: 1)
    chef_one.recipes.create!(servings: 1)
    chef_two.recipes.create!(servings: 1)
    chef_three.recipes.create!(servings: 1)

    assert_equal({"Bob" => 2, "Ali" => 1, "Alice" => 1}, Recipe.per_chef)
  end

  test ".with_description" do
    chef = Chef.create!
    chef.recipes.create!(id: 1, servings: 1, description: "he is here")
    chef.recipes.create!(id: 2, servings: 1, description: "hello world")
    chef.recipes.create!(id: 3, servings: 1)

    assert_equal [1, 2], Recipe.with_description.map(&:id)
    assert_equal [1, 2], Recipe.with_description("he").map(&:id)
    assert_equal [2], Recipe.with_description("hello").map(&:id)
  end

  test ".by_duration" do
    chef = Chef.create!
    chef.recipes.create!(
      name: "Recipe One",
      servings: 1,
      steps_attributes: [
        {
          description: "Step 1",
          duration: 10.minutes
        },
        {
          description: "Step 2",
          duration: 15.minutes
        }
      ]
    )
    chef.recipes.create!(
      name: "Recipe Two",
      servings: 1,
      steps_attributes: [
        {
          description: "Step 1"
        },
        {
          description: "Step 2",
          duration: 5.minutes
        }
      ]
    )

    assert_equal({"Recipe Two" => 300, "Recipe One" => 1500}, Recipe.by_duration)
  end

  test ".quick" do
    chef = Chef.create!
    chef.recipes.create!(
      name: "Quick",
      servings: 1,
      steps_attributes: [
        {
          description: "Step 1",
          duration: 10.minutes
        },
        {
          description: "Step 2",
          duration: 5.minutes
        }
      ]
    )
    chef.recipes.create!(
      name: "Not Quick",
      servings: 1,
      steps_attributes: [
        {
          description: "Step 1",
          duration: 10.minutes
        },
        {
          description: "Step 2",
          duration: 5.minutes
        },
        {
          description: "Step 3",
          duration: 1.minutes
        }
      ]
    )

    assert_equal ["Quick"], Recipe.quick.map(&:name)
  end

  test ".unhealthy" do
    chef = Chef.create!
    sugar = Ingredient.create!(name: "Sugar")
    egg = Ingredient.create!(name: "Egg")
    recipe_one = chef.recipes.create!(name: "Unhealthy Recipe", servings: 2)
    recipe_two = chef.recipes.create!(name: "Healthy Recipe", servings: 1)
    recipe_three = chef.recipes.create!(name: "Slightly Unhealthy Recipe", servings: 1)
    recipe_one.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_one.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_two.measurements.create!(ingredient: egg)
    recipe_three.measurements.create!(ingredient: sugar, grams: 10.00)

    assert_equal ["Unhealthy Recipe"], Recipe.unhealthy.map(&:name)
  end

  test ".with_ingredients" do
    chef = Chef.create!
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

    assert_equal ["Recipe With Egg", "Recipe with Sugar", "Recipe with Sugar and Egg"], Recipe.with_ingredients(["sugar", "egg"]).map(&:name)
  end
end
