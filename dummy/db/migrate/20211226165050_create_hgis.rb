class CreateHgis < ActiveRecord::Migration[6.1]
  def change
    create_table :hgis do |t|
      t.string :name
      t.integer :how_many
      t.text :hello

      t.timestamps
    end
  end
end
