class CreateMissingLabelTables < ActiveRecord::Migration[7.0]
  def change
    create_table :missing_label_tables do |t|

      t.timestamps
    end
  end
end
