class CreateCantelopes < ActiveRecord::Migration[7.0]
  def change
    create_table :cantelopes do |t|

      t.string :name
      t.string :_a_show_only_field
      t.timestamps
    end
  end
end
