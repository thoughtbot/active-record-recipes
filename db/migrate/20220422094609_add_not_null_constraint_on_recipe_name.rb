class AddNotNullConstraintOnRecipeName < ActiveRecord::Migration[7.0]
  def change
    change_column_null :recipes, :name, false
  end
end
