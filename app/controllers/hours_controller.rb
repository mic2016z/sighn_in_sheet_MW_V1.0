class HoursController < ApplicationController
  def show
    @organisation = current_organisation
    @from = parse_date(params[:from]) || Time.current.in_time_zone(@organisation.timezone).to_date.beginning_of_month
    @to = parse_date(params[:to]) || Time.current.in_time_zone(@organisation.timezone).to_date
    @location = @organisation.locations.find_by(id: params[:location_id])
    @locations = @organisation.locations.order(:name)

    @visits = visits_in_range.includes(:location).order(:signed_in_at)
    @by_person = @visits.group_by(&:person_name).transform_values do |visits|
      {
        visits: visits,
        total_hours: visits.sum(&:duration_hours).round(2),
        session_count: visits.size,
        any_auto_closed: visits.any?(&:auto_closed?)
      }
    end.sort_by { |name, _| name.downcase }
  end

  def export
    @organisation = current_organisation
    @from = parse_date(params[:from]) || Time.current.in_time_zone(@organisation.timezone).to_date.beginning_of_month
    @to = parse_date(params[:to]) || Time.current.in_time_zone(@organisation.timezone).to_date
    @location = @organisation.locations.find_by(id: params[:location_id])

    send_data csv_for(visits_in_range.includes(:location).order(:signed_in_at)),
      filename: "hours-#{@from}-to-#{@to}.csv", type: "text/csv"
  end

  private

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end

  def visits_in_range
    scope = @organisation.visits.where(
      signed_in_at: @from.in_time_zone(@organisation.timezone).beginning_of_day..@to.in_time_zone(@organisation.timezone).end_of_day
    )
    @location ? scope.where(location: @location) : scope
  end

  def csv_for(visits)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << [ "Person", "Date", "Sign-in time", "Sign-out time", "Duration (hrs)", "Program", "Location", "Auto-closed", "Signed" ]
      visits.each do |visit|
        tz = @organisation.timezone
        csv << [
          visit.person_name,
          visit.signed_in_at.in_time_zone(tz).to_date.iso8601,
          visit.signed_in_at.in_time_zone(tz).strftime("%H:%M"),
          visit.signed_out_at&.in_time_zone(tz)&.strftime("%H:%M"),
          visit.duration_hours,
          visit.program,
          visit.location.name,
          visit.auto_closed? ? "Yes" : "No",
          visit.signed? ? "Yes" : "No"
        ]
      end
    end
  end
end
