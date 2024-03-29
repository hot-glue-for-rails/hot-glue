class CreateJkls < ActiveRecord::Migration[6.1]
  def change
    create_enum :genre, %w[Fiction Nonfiction Mystery Romance Novel]

    create_table :jkls do |t|
      t.integer :hgi_id

      t.string :name
      t.string :blurb
      t.text :long_description
      t.float :cost
      t.integer :how_many_printed
      t.datetime :approved_at
      t.date :release_on
      t.time :time_of_day
      t.boolean :selected
      t.enum :genre, enum_type: :genre
      t.timestamps
    end
  end
end
