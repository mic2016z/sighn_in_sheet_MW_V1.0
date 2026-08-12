class VisitsController < ApplicationController
  before_action :set_location, only: [ :show, :create, :confirm_sign_in ]
  before_action :set_visit, only: [ :edit, :update, :destroy, :sign_out ]

  def show
    @recent_people = @location.recent_people
    @open_visit_by_person_id = @location.open_visits_by_person_id
  end

  # Step 1: resolve the person. Signing OUT happens immediately (fast path).
  # Signing IN pauses on a "sign here" screen before the visit is created.
  def create
    person = find_or_create_person
    open_visit = @location.visits.open_now.find_by(person_id: person.id)

    if open_visit
      open_visit.sign_out!
      @result = :signed_out
      @visit = open_visit
      render :confirmation
    else
      @person = person
      @program = params[:program].presence
      render :sign_here
    end
  end

  # Step 2: the signed canvas comes back here and the visit is actually created.
  def confirm_sign_in
    person = @location.organisation.people.find(params[:person_id])

    @visit = @location.visits.create!(
      organisation: @location.organisation,
      person: person,
      person_name: person.full_name,
      program: params[:program].presence,
      signed_in_at: Time.current,
      signature_data: params[:signature].presence
    )
    @result = :signed_in
    render :confirmation
  end

  def edit
  end

  def update
    @visit.assign_attributes(visit_params)
    @visit.edited_by = "staff edit"
    @visit.auto_closed = false if @visit.signed_out_at_changed?

    if @visit.save
      redirect_to register_path(date: visit_date), notice: "Entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @visit.destroy
    redirect_to register_path(date: visit_date), notice: "Entry removed."
  end

  def sign_out
    @visit.sign_out!(edited_by: "staff") if @visit.open?
    redirect_back fallback_location: register_path, notice: "#{@visit.person_name} signed out."
  end

  private

  def set_location
    @location = Location.find_by!(slug: params[:slug])
  end

  def set_visit
    @visit = current_organisation.visits.find(params[:id])
  end

  def visit_params
    params.require(:visit).permit(:signed_in_at, :signed_out_at, :program)
  end

  def visit_date
    @visit.signed_in_at.in_time_zone(current_organisation.timezone).to_date
  end

  def find_or_create_person
    if params[:person_id].present?
      @location.organisation.people.find(params[:person_id])
    else
      Person.find_or_create_by_name!(organisation: @location.organisation, full_name: params[:name])
    end
  end
end
