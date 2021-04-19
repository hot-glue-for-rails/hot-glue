class CreateGhis < ActiveRecord::Migration[6.1]
  def change
    create_table :ghis do |t|
      t.integer :def_id

      t.timestamps
    end
  end
end
