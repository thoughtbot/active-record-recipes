class AddNameIndexToChefs < ActiveRecord::Migration[7.0]
  def change
    change_column_null :chefs, :name, false
    add_index :chefs, :name, unique: true
  end
end
