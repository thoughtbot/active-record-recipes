require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "should be valid" do
    chef = Chef.create!(name: "Name")
    recipe = chef.recipes.new(name: "Recipe", servings: 1)

    assert recipe.valid?
  end

  test "should have name" do
    chef = Chef.create!(name: "Chef")
    recipe = chef.recipes.new(name: nil, servings: 1)

    assert_not recipe.valid?
  end

  test "name should be unique per chef" do
    chef_one = Chef.create!(name: "Chef One")
    chef_two = Chef.create!(name: "Chef Two")
    chef_one.recipes.create!(name: "Recipe", servings: 1)
    chef_two.recipes.create!(name: "Recipe", servings: 1)
    recipe = chef_one.recipes.new(name: "Recipe", servings: 1)

    assert_not recipe.valid?
  end

  test "#ingredients" do
    ingredient = Ingredient.create!
    chef = Chef.create!(name: "Name")
    recipe = chef.recipes.create!(name: "Recipe", servings: 1)
    ingredient.measurements.create!(recipe: recipe)

    assert_includes recipe.ingredients, ingredient
  end

  test "#measurements" do
    ingredient = Ingredient.create!
    chef = Chef.create!(name: "Name")
    recipe = chef.recipes.create!(name: "Recipe", servings: 1)

    assert_difference("Measurement.count", 1) do
      ingredient.measurements.create!(recipe: recipe)
    end

    assert_difference("Measurement.count", -1) do
      recipe.destroy
    end
  end

  test "#description" do
    chef = Chef.create!(name: "Name")

    assert_difference("ActionText::RichText.count", 1) do
      chef.recipes.create!(name: "Recipe", description: "some description", servings: 1)
    end
  end

  test ".latest_per_chef" do
    chef_one = Chef.create!(name: "Chef One")
    chef_two = Chef.create!(name: "Chef Two")
    chef_one.recipes.create!(name: "Latest Recipe For Chef One", servings: 1, created_at: 1.hour.ago)
    chef_one.recipes.create!(name: "First Recipe For Chef One", servings: 1, created_at: 1.day.ago)
    chef_two.recipes.create!(name: "Latest Recipe For Chef Two", servings: 1, created_at: 1.hour.ago)
    chef_two.recipes.create!(name: "First Recipe For Chef Two", servings: 1, created_at: 1.day.ago)

    assert_equal ["Latest Recipe For Chef One", "Latest Recipe For Chef Two"], Recipe.latest_per_chef.map(&:name)
  end

  test ".first_per_chef" do
    chef_one = Chef.create!(name: "Chef One")
    chef_two = Chef.create!(name: "Chef Two")
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
    chef_one.recipes.create!(name: "Recipe One", servings: 1)
    chef_one.recipes.create!(name: "Recipe Two", servings: 1)
    chef_two.recipes.create!(name: "Recipe Three", servings: 1)
    chef_three.recipes.create!(name: "Recipe Four", servings: 1)

    assert_equal({"Bob" => 2, "Ali" => 1, "Alice" => 1}, Recipe.per_chef)
    assert_equal(["Bob", 2], Recipe.per_chef.first)
  end

  test ".with_description_containing" do
    chef = Chef.create!(name: "Name")
    chef.recipes.create!(name: "Recipe One", servings: 1, description: "he is here")
    chef.recipes.create!(name: "Recipe Two", servings: 1, description: "hello world")
    chef.recipes.create!(name: "Recipe Three", servings: 1)

    assert_equal ["Recipe One", "Recipe Two"], Recipe.with_description_containing("").map(&:name)
    assert_equal ["Recipe One", "Recipe Two"], Recipe.with_description_containing("he").map(&:name)
    assert_equal ["Recipe Two"], Recipe.with_description_containing("hello").map(&:name)
  end

  test ".by_duration" do
    chef = Chef.create!(name: "Name")
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
    assert_equal(["Recipe Two", 300], Recipe.by_duration.first)
  end

  test ".quick" do
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

    assert_equal ["Quick"], Recipe.quick.map(&:name)
  end

  test ".sweet" do
    chef = Chef.create!(name: "Name")
    sugar = Ingredient.create!(name: "Sugar")
    egg = Ingredient.create!(name: "Egg")
    recipe_one = chef.recipes.create!(name: "Sweet Recipe", servings: 2)
    recipe_two = chef.recipes.create!(name: "Healthy Recipe", servings: 1)
    recipe_three = chef.recipes.create!(name: "Slightly Sweet Recipe", servings: 1)
    recipe_one.measurements.create!(ingredient: sugar, grams: 20.00)
    recipe_one.measurements.create!(ingredient: sugar, grams: 12.00)
    recipe_one.measurements.create!(ingredient: sugar, grams: 8.00)
    recipe_two.measurements.create!(ingredient: egg)
    recipe_three.measurements.create!(ingredient: sugar, grams: 10.00)

    assert_equal ["Sweet Recipe"], Recipe.sweet.map(&:name)
  end

  test ".with_ingredients" do
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

    assert_equal ["Recipe With Egg", "Recipe with Sugar", "Recipe with Sugar and Egg"], Recipe.with_ingredients(["sugar", "egg"]).map(&:name)
  end

  test ".by_average_rating" do
    chef_one = Chef.create!(name: "Chef One")
    chef_two = Chef.create!(name: "Chef Two")
    highly_rated_recipe_chef_one = chef_one.recipes.create!(name: "Highly Rated Recipe", servings: 1)
    poorly_rated_recipe_chef_one = chef_one.recipes.create!(name: "Poorly Rated Recipe", servings: 1)
    highly_rated_recipe_chef_two = chef_two.recipes.create!(name: "Highly Rated Recipe", servings: 1)
    chef_one.recipes.create!(name: "Without Reviews", servings: 1)
    highly_rated_recipe_chef_one.reviews.create!(rating: 5)
    highly_rated_recipe_chef_one.reviews.create!(rating: 4)
    highly_rated_recipe_chef_two.reviews.create!(rating: 5)
    poorly_rated_recipe_chef_one.reviews.create!(rating: 1)
    poorly_rated_recipe_chef_one.reviews.create!(rating: 2)

    assert_equal(
      {
        ["Highly Rated Recipe", "Chef Two"] => 5,
        ["Highly Rated Recipe", "Chef One"] => 4.5,
        ["Poorly Rated Recipe", "Chef One"] => 1.5
      },
      Recipe.by_average_rating
    )
    assert_equal([["Highly Rated Recipe", "Chef Two"], 5], Recipe.by_average_rating.first)
  end

  test ".with_average_rating_above" do
    chef_one = Chef.create!(name: "Chef One")
    chef_two = Chef.create!(name: "Chef Two")
    highly_rated_recipe_chef_one = chef_one.recipes.create!(name: "Highly Rated Recipe", servings: 1)
    poorly_rated_recipe_chef_one = chef_one.recipes.create!(name: "Poorly Rated Recipe", servings: 1)
    highly_rated_recipe_chef_two = chef_two.recipes.create!(name: "Highly Rated Recipe", servings: 1)
    chef_one.recipes.create!(name: "Without Reviews", servings: 1)
    highly_rated_recipe_chef_one.reviews.create!(rating: 5)
    highly_rated_recipe_chef_one.reviews.create!(rating: 4)
    highly_rated_recipe_chef_two.reviews.create!(rating: 5)
    poorly_rated_recipe_chef_one.reviews.create!(rating: 1)
    poorly_rated_recipe_chef_one.reviews.create!(rating: 2)

    assert_equal(
      ["Highly Rated Recipe (Chef Two)", "Highly Rated Recipe (Chef One)"],
      Recipe.with_average_rating_above(4.4).map { |recipe| "#{recipe.name} (#{recipe.chef.name})" }
    )
    assert_equal(
      ["Highly Rated Recipe (Chef Two)", "Highly Rated Recipe (Chef One)", "Poorly Rated Recipe (Chef One)"],
      Recipe.with_average_rating_above(1.4).map { |recipe| "#{recipe.name} (#{recipe.chef.name})" }
    )
  end
end
