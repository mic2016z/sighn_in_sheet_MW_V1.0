class Person < ApplicationRecord
  belongs_to :organisation
  has_many :visits, dependent: :nullify

  validates :full_name, presence: true

  scope :active, -> { where(active: true) }

  def self.find_or_create_by_name!(organisation:, full_name:)
    name = full_name.to_s.strip
    organisation.people.where("lower(full_name) = ?", name.downcase).first ||
      organisation.people.create!(full_name: name)
  end
end
