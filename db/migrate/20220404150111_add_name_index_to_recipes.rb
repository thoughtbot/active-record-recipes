class AddNameIndexToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_index(:recipes, [:name, :chef_id], unique: true)
  end
end
