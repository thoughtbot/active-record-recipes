require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "should be valid" do
    chef = Chef.create!
    recipe = chef.recipes.new

    assert recipe.valid?
  end

  test "#description" do
    chef = Chef.create!

    assert_difference("ActionText::RichText.count", 1) do
      chef.recipes.create!(description: "some description")
    end
  end

  test ".latest_per_chef" do
    chef_one = Chef.create!
    chef_two = Chef.create!
    chef_one.recipes.create!(name: "Latest Recipe For Chef One", created_at: 1.hour.ago)
    chef_one.recipes.create!(name: "First Recipe For Chef One", created_at: 1.day.ago)
    chef_two.recipes.create!(name: "Latest Recipe For Chef Two", created_at: 1.hour.ago)
    chef_two.recipes.create!(name: "First Recipe For Chef Two", created_at: 1.day.ago)

    assert_equal ["Latest Recipe For Chef One", "Latest Recipe For Chef Two"], Recipe.latest_per_chef.map(&:name)
  end

  test ".first_per_chef" do
    chef_one = Chef.create!
    chef_two = Chef.create!
    chef_one.recipes.create!(name: "Latest Recipe For Chef One", created_at: 1.hour.ago)
    chef_one.recipes.create!(name: "First Recipe For Chef One", created_at: 1.day.ago)
    chef_two.recipes.create!(name: "Latest Recipe For Chef Two", created_at: 1.hour.ago)
    chef_two.recipes.create!(name: "First Recipe For Chef Two", created_at: 1.day.ago)

    assert_equal ["First Recipe For Chef One", "First Recipe For Chef Two"], Recipe.first_per_chef.map(&:name)
  end

  test ".per_chef" do
    chef_one = Chef.create!(id: 1)
    chef_two = Chef.create!(id: 2)
    chef_one.recipes.create!
    chef_one.recipes.create!
    chef_two.recipes.create!

    assert_equal({1 => 2, 2 => 1}, Recipe.per_chef)
  end

  test ".with_description" do
    chef = Chef.create!
    chef.recipes.create!(id: 1, description: "he is here")
    chef.recipes.create!(id: 2, description: "hello world")
    chef.recipes.create!(id: 3)

    assert_equal [1, 2], Recipe.with_description.map(&:id)
    assert_equal [1, 2], Recipe.with_description("he").map(&:id)
    assert_equal [2], Recipe.with_description("hello").map(&:id)
  end

  test ".by_duration" do
    chef = Chef.create!
    chef.recipes.create!(
      name: "Recipe 1",
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
      name: "Recipe 1",
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

    assert_equal [300, 1500], Recipe.by_duration.values.map(&:to_i).sort
  end

  test ".quick" do
    chef = Chef.create!
    chef.recipes.create!(
      name: "Quick",
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
end
