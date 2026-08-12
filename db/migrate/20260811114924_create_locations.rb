class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :programs

      t.timestamps
    end

    add_index :locations, :slug, unique: true
  end
end
