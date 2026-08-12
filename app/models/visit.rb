class Visit < ApplicationRecord
  belongs_to :organisation
  belongs_to :location
  belongs_to :person

  validates :person_name, presence: true
  validates :signed_in_at, presence: true

  scope :open_now, -> { where(signed_out_at: nil) }
  scope :closed, -> { where.not(signed_out_at: nil) }
  scope :on_date, ->(date, tz) { where(signed_in_at: date.in_time_zone(tz).all_day) }

  after_commit :broadcast_to_dashboard

  def open?
    signed_out_at.nil?
  end

  def signed?
    signature_data.present?
  end

  # signature_data is a data: URL (e.g. "data:image/png;base64,...."); this
  # strips the header so callers get raw bytes for embedding (PDF, <img>).
  def signature_png_bytes
    return nil unless signed?
    Base64.decode64(signature_data.split(",", 2).last)
  end

  def duration
    ((signed_out_at || Time.current) - signed_in_at)
  end

  def duration_hours
    (duration / 3600.0).round(2)
  end

  def sign_out!(at: Time.current, auto_closed: false, edited_by: nil)
    update!(signed_out_at: at, auto_closed: auto_closed, edited_by: edited_by)
  end

  private

  def broadcast_to_dashboard
    broadcast_replace_later_to(
      [ organisation, :register ],
      target: "on_site",
      partial: "register/on_site",
      locals: { organisation: organisation }
    )
  end
end
