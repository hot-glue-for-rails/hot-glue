class CreateXyzs < ActiveRecord::Migration[6.1]
  def change
    create_table :xyzs do |t|
      t.integer :nothing_id
      t.integer :user_id
      t.timestamps
    end
  end
end
