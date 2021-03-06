class CreateHgis < ActiveRecord::Migration[6.1]
  def change
    create_table :hgis do |t|
      t.integer :def_id

      t.timestamps
    end
  end
end
