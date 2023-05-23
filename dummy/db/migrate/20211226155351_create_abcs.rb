class CreateAbcs < ActiveRecord::Migration[7.0]
  def change
    create_table :abcs do |t|
      t.string :name

      t.timestamps
    end
  end
end
