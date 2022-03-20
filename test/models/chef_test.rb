require "test_helper"

class ChefTest < ActiveSupport::TestCase
  test "should be valid" do
    chef = Chef.new

    assert chef.valid?
  end

  test "association with recipe" do
    chef = Chef.create!

    assert_difference("chef.recipes.count", 1) do
      chef.recipes.create!
    end

    assert_difference("chef.recipes.count", -1) do
      chef.destroy!
    end
  end

  test ".first_recipe" do
    chef = Chef.create!
    chef.recipes.create!(name: "Latest Recipe", created_at: 1.day.ago)
    chef.recipes.create!(name: "First Recipe", created_at: 1.week.ago)

    assert_equal "First Recipe", chef.first_recipe.name
  end

  test ".latest_recipe" do
    chef = Chef.create!
    chef.recipes.create!(name: "Latest Recipe", created_at: 1.day.ago)
    chef.recipes.create!(name: "First Recipe", created_at: 1.week.ago)

    assert_equal "Latest Recipe", chef.latest_recipe.name
  end
end
