class AddSignatureDataToVisits < ActiveRecord::Migration[8.1]
  def change
    add_column :visits, :signature_data, :text
  end
end
