class CreateJkls < ActiveRecord::Migration[6.1]
  def change
    create_table :jkls do |t|
      t.integer :hgi_id

      t.timestamps
    end
  end
end
