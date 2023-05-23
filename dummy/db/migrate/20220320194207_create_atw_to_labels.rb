class CreateAtwToLabels < ActiveRecord::Migration[6.1]
  def change
    create_table :atw_to_labels do |t|
      t.string :to_label
      t.integer :xyz_id

      t.timestamps
    end
  end
end
