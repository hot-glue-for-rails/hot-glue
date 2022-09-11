class CreateAtwFullNames < ActiveRecord::Migration[6.1]
  def change
    create_table :atw_full_names do |t|
      t.string :full_name
      t.integer :xyz_id

      t.timestamps
    end
  end
end
