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
end
