class PeopleController < ApplicationController
  def index
    @people = current_organisation.people.order(:full_name)
  end

  def new
  end

  def create
    names = params[:names].to_s.split("\n").map(&:strip).reject(&:blank?)
    names.each { |name| Person.find_or_create_by_name!(organisation: current_organisation, full_name: name) }

    redirect_to people_path, notice: "Added #{names.size} #{'person'.pluralize(names.size)}."
  end
end
