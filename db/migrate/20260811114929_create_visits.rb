class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.references :organisation, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :person_name, null: false
      t.string :program
      t.datetime :signed_in_at, null: false
      t.datetime :signed_out_at
      t.boolean :auto_closed, null: false, default: false
      t.string :edited_by

      t.timestamps
    end

    add_index :visits, [ :location_id, :signed_in_at ]
    add_index :visits, [ :organisation_id, :signed_out_at ]
  end
end
