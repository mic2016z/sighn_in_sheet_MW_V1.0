class ManualEntriesController < ApplicationController
  # Staff-assisted sign-in from a shared computer or iPad: enter a name,
  # pick the arrival time on the wheel (defaults to 3:00 PM), done.
  def new
    @organisation = current_organisation
    @locations = @organisation.locations.order(:name)
    @people = @organisation.people.active.order(:full_name)
  end

  def create
    organisation = current_organisation
    location = organisation.locations.find(params[:location_id])
    person = Person.find_or_create_by_name!(organisation: organisation, full_name: params[:name])

    if location.visits.open_now.exists?(person_id: person.id)
      redirect_to new_manual_entry_path, alert: "#{person.full_name} is already signed in at #{location.name}."
      return
    end

    signed_in_at = arrival_time(organisation)

    location.visits.create!(
      organisation: organisation,
      person: person,
      person_name: person.full_name,
      program: params[:program].presence,
      signed_in_at: signed_in_at,
      edited_by: "staff manual entry",
      signature_data: params[:signature].presence
    )

    redirect_to register_path, notice: "#{person.full_name} signed in at #{signed_in_at.strftime('%-l:%M %p')}."
  end

  private

  # params[:time] arrives as "HH:MM" (24h) from the wheel; anchor it to today
  # in the organisation's timezone. Guard against malformed input.
  def arrival_time(organisation)
    hour, minute = params[:time].to_s.split(":").map(&:to_i)
    hour = hour.clamp(0, 23)
    minute = minute.clamp(0, 59)
    Time.use_zone(organisation.timezone) { Time.zone.now.change(hour: hour, min: minute) }
  end
end
