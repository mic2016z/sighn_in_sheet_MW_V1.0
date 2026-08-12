class CreateOrganisations < ActiveRecord::Migration[8.1]
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.string :contact_email
      t.integer :default_auto_close_hours, null: false, default: 4
      t.string :timezone, null: false, default: "Australia/Sydney"

      t.timestamps
    end
  end
end
