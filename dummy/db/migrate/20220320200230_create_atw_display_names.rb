class CreateAtwDisplayNames < ActiveRecord::Migration[7.0]
  def change
    create_table :atw_display_names do |t|
      t.string :display_name
      t.integer :xyz_id

      t.timestamps
    end
  end
end
