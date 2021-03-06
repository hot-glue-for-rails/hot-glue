class CreateOmnitableBs < ActiveRecord::Migration[6.1]
  def change
    create_table :omnitable_bs do |t|
      t.integer :field_integer
      t.string :field_string
      t.text :field_text
      t.float :field_float
      t.datetime :field_datetime
      t.date :field_date
      t.time :field_time
      t.boolean :field_boolean

      t.timestamps
    end
  end
end
