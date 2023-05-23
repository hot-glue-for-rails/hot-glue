class CreateHuman < ActiveRecord::Migration[7.0]
  def change
    create_table :humans do |t|
      t.string :name

      t.timestamps
    end
  end
end
