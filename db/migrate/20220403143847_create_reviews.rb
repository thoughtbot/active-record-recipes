class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :recipe, null: false, foreign_key: true
      t.integer :rating
      t.check_constraint("rating >= 0 AND rating <= 5", name: "rating_check")

      t.timestamps
    end
  end
end
