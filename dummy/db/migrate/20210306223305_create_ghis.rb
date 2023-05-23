class CreateGhis < ActiveRecord::Migration[6.1]
  def change
    create_table :ghis do |t|
      t.integer :dfg_id
      t.integer :xyz_id
      t.timestamps
    end
  end
end
