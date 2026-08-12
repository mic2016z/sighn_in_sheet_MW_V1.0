class Location < ApplicationRecord
  belongs_to :organisation
  has_many :visits, dependent: :destroy

  serialize :programs, coder: JSON, type: Array

  before_validation :generate_slug, on: :create

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9\-]+\z/, message: "can only contain lowercase letters, numbers and dashes" }

  def programs
    super.presence || []
  end

  def multiple_programs?
    programs.size > 1
  end

  # Most-recently-seen people at this location, for the one-tap sign-in list.
  def recent_people(limit: 12, days: 30)
    person_ids = visits.where(signed_in_at: days.days.ago..)
      .order(signed_in_at: :desc)
      .pluck(:person_id)
      .uniq
      .first(limit)

    people = Person.where(id: person_ids).index_by(&:id)
    person_ids.filter_map { |id| people[id] }
  end

  def open_visits_by_person_id
    visits.open_now.index_by(&:person_id)
  end

  private

  def generate_slug
    return if slug.present?

    base = name.to_s.parameterize
    candidate = base
    n = 1
    while Location.exists?(slug: candidate)
      n += 1
      candidate = "#{base}-#{n}"
    end
    self.slug = candidate
  end
end
