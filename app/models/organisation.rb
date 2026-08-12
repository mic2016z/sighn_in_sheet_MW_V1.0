class Organisation < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :visits, dependent: :destroy

  validates :name, presence: true
  validates :default_auto_close_hours, numericality: { greater_than: 0 }
  validates :timezone, presence: true
end
