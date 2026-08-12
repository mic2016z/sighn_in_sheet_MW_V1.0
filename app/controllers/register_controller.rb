class RegisterController < ApplicationController
  def show
    @organisation = current_organisation
    @date = parse_date(params[:date]) || Time.current.in_time_zone(@organisation.timezone).to_date
    @location = @organisation.locations.find_by(id: params[:location_id])

    @visits = visits_for(@date, @location).order(:signed_in_at).includes(:location)
    @on_site = @organisation.visits.open_now.order(:signed_in_at)
    @locations = @organisation.locations.order(:name)

    @prev_date = @date.prev_day
    @next_date = @date.next_day
  end

  def export
    @organisation = current_organisation
    from = parse_date(params[:from]) || parse_date(params[:date]) || Time.current.in_time_zone(@organisation.timezone).to_date
    to = parse_date(params[:to]) || from
    location = @organisation.locations.find_by(id: params[:location_id])

    visits = @organisation.visits
      .where(signed_in_at: from.in_time_zone(@organisation.timezone).beginning_of_day..to.in_time_zone(@organisation.timezone).end_of_day)
      .then { |scope| location ? scope.where(location: location) : scope }
      .order(:signed_in_at)
      .includes(:location)

    send_data csv_for(visits), filename: "sign-in-sheet-#{from}-to-#{to}.csv", type: "text/csv"
  end

  def pdf
    @organisation = current_organisation
    date = parse_date(params[:date]) || Time.current.in_time_zone(@organisation.timezone).to_date
    location = @organisation.locations.find_by(id: params[:location_id])

    visits = visits_for(date, location).order(:signed_in_at).includes(:location)
    pdf_bytes = RegisterPdf.new(organisation: @organisation, date: date, location: location, visits: visits).render

    filename = [ "sign-in-sheet", location&.name&.parameterize, date.iso8601 ].compact.join("-") + ".pdf"
    send_data pdf_bytes, filename: filename, type: "application/pdf", disposition: "inline"
  end

  private

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end

  def visits_for(date, location)
    scope = @organisation.visits.where(signed_in_at: date.in_time_zone(@organisation.timezone).all_day)
    location ? scope.where(location: location) : scope
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
