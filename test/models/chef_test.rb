require "test_helper"

class ChefTest < ActiveSupport::TestCase
  test "should be valid" do
    chef = Chef.new(name: "Name")

    assert chef.valid?
  end

  test "association with recipe" do
    chef = Chef.create!(name: "Name")

    assert_difference("chef.recipes.count", 1) do
      chef.recipes.create!(servings: 1)
    end

    assert_difference("chef.recipes.count", -1) do
      chef.destroy!
    end
  end

  test "should have name" do
    chef = Chef.new

    assert_not chef.valid?
  end

  test "name should be unique" do
    Chef.create!(name: "Name")
    chef = Chef.new(name: "Name")

    assert_not chef.valid?
  end

  test "#unhealthy_recipes" do
    chef_one = Chef.create!(name: "Unhealthy")
    chef_two = Chef.create!(name: "Healthy")
    sugar = Ingredient.create!(name: "Sugar")
    egg = Ingredient.create!(name: "Egg")
    recipe_one = chef_one.recipes.create!(name: "Unhealthy Recipe", servings: 2)
    recipe_two = chef_two.recipes.create!(name: "Healthy Recipe", servings: 1)
    recipe_three = chef_one.recipes.create!(name: "Slightly Unhealthy Recipe", servings: 1)
    recipe_one.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_one.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_two.measurements.create!(ingredient: egg)
    recipe_three.measurements.create!(ingredient: sugar, grams: 10.00)

    assert_equal ["Unhealthy Recipe"], chef_one.unhealthy_recipes.map(&:name)
    assert_empty chef_two.unhealthy_recipes.map(&:name)
  end

  test "#quick_recipes" do
    chef = Chef.create!(name: "Name")
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

    assert_equal ["Quick"], chef.quick_recipes.map(&:name)
  end

  test ".first_recipe" do
    chef = Chef.create!(name: "Name")
    chef.recipes.create!(name: "Latest Recipe", servings: 1, created_at: 1.day.ago)
    chef.recipes.create!(name: "First Recipe", servings: 1, created_at: 1.week.ago)

    assert_equal "First Recipe", chef.first_recipe.name
  end

  test ".latest_recipe" do
    chef = Chef.create!(name: "Name")
    chef.recipes.create!(name: "Latest Recipe", servings: 1, created_at: 1.day.ago)
    chef.recipes.create!(name: "First Recipe", servings: 1, created_at: 1.week.ago)

    assert_equal "Latest Recipe", chef.latest_recipe.name
  end

  test ".with_unhealthy_recipes" do
    chef_one = Chef.create!(name: "Chef With Unhealthy Recipes")
    chef_two = Chef.create!(name: "Chef Wit Healthy Recipes")
    chef_three = Chef.create!(name: "Another Chef With Unhealthy Recipes")
    sugar = Ingredient.create!(name: "Sugar")
    egg = Ingredient.create!(name: "Egg")
    recipe_one = chef_one.recipes.create!(name: "Unhealthy Recipe", servings: 2)
    recipe_two = chef_two.recipes.create!(name: "Healthy Recipe", servings: 1)
    recipe_three = chef_one.recipes.create!(name: "Slightly Unhealthy Recipe", servings: 1)
    recipe_four = chef_three.recipes.create!(name: "Another Slightly Unhealthy Recipe", servings: 1)
    recipe_five = chef_three.recipes.create!(name: "Another Unhealthy Recipe", servings: 1)
    recipe_one.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_one.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_two.measurements.create!(ingredient: egg)
    recipe_three.measurements.create!(ingredient: sugar, grams: 10.00)
    recipe_four.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_five.measurements.create!(ingredient: sugar, grams: 20.00)

    assert_equal ["Another Chef With Unhealthy Recipes", "Chef With Unhealthy Recipes"], Chef.with_unhealthy_recipes.map(&:name)
  end

  test ".with_quick_recipes" do
    chef_one = Chef.create!(name: "Chef With Quick Recipes")
    chef_two = Chef.create!(name: "Chef Without Quick Recipe")
    chef_three = Chef.create!(name: "Another Chef With Quick Recipes")
    chef_one.recipes.create!(
      name: "Quick Recipe",
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
    chef_one.recipes.create!(
      name: "Another Quick Recipe",
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
    chef_two.recipes.create!(
      name: "Not Quick Recipe",
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
    chef_three.recipes.create!(
      name: "Not Quick Recipe",
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
    chef_three.recipes.create!(
      name: "A Quick Recipe",
      servings: 1,
      steps_attributes: [
        {
          description: "Step 1",
          duration: 10.minutes
        },
        {
          description: "Step 2",
          duration: 4.minutes
        },
        {
          description: "Step 3",
          duration: 1.minutes
        }
      ]
    )

    assert_equal ["Another Chef With Quick Recipes", "Chef With Quick Recipes"], Chef.with_quick_recipes.map(&:name)
  end

  test ".with_recipes_with_ingredients" do
    chef_one = Chef.create!(name: "Chef One")
    chef_two = Chef.create!(name: "Chef Two")
    sugar = Ingredient.create!(name: "Sugar")
    egg = Ingredient.create!(name: "Egg")
    flour = Ingredient.create!(name: "Flour")
    recipe_one = chef_one.recipes.create!(name: "Recipe with Sugar", servings: 1)
    recipe_two = chef_one.recipes.create!(name: "Recipe With Egg", servings: 1)
    recipe_three = chef_one.recipes.create!(name: "Recipe With Flour", servings: 1)
    recipe_four = chef_two.recipes.create!(name: "Recipe with Sugar and Egg", servings: 1)
    recipe_one.measurements.create!(ingredient: sugar)
    recipe_two.measurements.create!(ingredient: egg)
    recipe_three.measurements.create!(ingredient: flour)
    recipe_four.measurements.create!(ingredient: sugar)
    recipe_four.measurements.create!(ingredient: egg)

    assert_equal ["Chef One", "Chef Two"], Chef.with_recipes_with_ingredients(["sugar"]).map(&:name)
    assert_equal ["Chef One", "Chef Two"], Chef.with_recipes_with_ingredients(["sugar", "egg"]).map(&:name)
    assert_equal ["Chef One"], Chef.with_recipes_with_ingredients(["flour"]).map(&:name)
    assert_equal ["Chef One", "Chef Two"], Chef.with_recipes_with_ingredients(["sugar", "egg", "flour"]).map(&:name)
  end
end
