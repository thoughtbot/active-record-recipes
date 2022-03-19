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
end
