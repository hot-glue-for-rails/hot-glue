class CreateBorkeds < ActiveRecord::Migration[7.0]
  def change
    create_table :borkeds do |t|
      t.integer :xyz_id

      t.integer :missing_label_table_id
      t.timestamps
    end
  end
end
