class CreateJkls < ActiveRecord::Migration[6.1]
  def change
    # create_enum 'genres', %w[Fiction Nonfiction Mystery Romance Novel]

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
      t.integer :genre
      # t.enum :genre, as: :genres
      t.timestamps
    end
  end
end
