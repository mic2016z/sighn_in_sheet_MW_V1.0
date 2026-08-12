class AutoCloseVisitsJob < ApplicationJob
  queue_as :default

  def perform
    Organisation.find_each do |organisation|
      organisation.visits.open_now.find_each do |visit|
        closed_at = visit.signed_in_at + organisation.default_auto_close_hours.hours
        visit.sign_out!(at: closed_at, auto_closed: true)
      end
    end
  end
end
