class AddCantelopeIdToDfgs < ActiveRecord::Migration[6.1]
  def change

    add_column :dfgs, :cantelope_id, :integer
  end
end
