class CreateHuman < ActiveRecord::Migration[6.1]
  def change
    create_table :humen do |t|
      t.string :name

      t.timestamps
    end
  end
end
