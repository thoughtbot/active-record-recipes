class AddServingsToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :servings, :integer, null: false
  end
end
