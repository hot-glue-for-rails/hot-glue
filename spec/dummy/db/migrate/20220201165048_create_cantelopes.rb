class CreateCantelopes < ActiveRecord::Migration[6.1]
  def change
    create_table :cantelopes do |t|

      t.string :name
      t.timestamps
    end
  end
end
