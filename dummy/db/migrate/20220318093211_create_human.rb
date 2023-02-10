class CreateHuman < ActiveRecord::Migration[6.1]
  def change
    create_table :humans do |t|
      t.string :name

      t.timestamps
    end
  end
end
