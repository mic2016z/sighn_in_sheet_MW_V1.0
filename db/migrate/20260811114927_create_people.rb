class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :people do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :full_name, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :people, [ :organisation_id, :full_name ]
  end
end
