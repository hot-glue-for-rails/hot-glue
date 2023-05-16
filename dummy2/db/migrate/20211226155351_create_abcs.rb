class CreateAbcs < ActiveRecord::Migration[6.1]
  def change
    create_table :abcs do |t|
      t.string :name

      t.timestamps
    end
  end
end
