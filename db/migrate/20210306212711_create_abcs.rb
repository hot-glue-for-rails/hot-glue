class CreateAbcs < ActiveRecord::Migration[6.1]
  def change
    create_table :abcs do |t|
      t.integer :xxx
      t.string :yyy
      t.integer :def_id

      t.timestamps
    end
  end
end
