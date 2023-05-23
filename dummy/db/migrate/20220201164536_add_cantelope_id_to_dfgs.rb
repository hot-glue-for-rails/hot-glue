class AddCantelopeIdToDfgs < ActiveRecord::Migration[7.0]
  def change

    add_column :dfgs, :cantelope_id, :integer
  end
end
