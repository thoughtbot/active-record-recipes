require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  setup do
    @chef = Chef.create!
  end

  test "should be valid" do
    recipe = @chef.recipes.new

    assert recipe.valid?
  end

  test "#description" do
    assert_difference("ActionText::RichText.count", 1) do
      @chef.recipes.create!(description: "some description")
    end
  end
end
