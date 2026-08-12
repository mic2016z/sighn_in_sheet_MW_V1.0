class LocationsController < ApplicationController
  def index
    @locations = current_organisation.locations.order(:name)
  end

  def new
    @location = current_organisation.locations.new
  end

  def create
    @location = current_organisation.locations.new(location_params)
    @location.programs = params[:programs].to_s.split(",").map(&:strip).reject(&:blank?)

    if @location.save
      redirect_to poster_location_path(@location), notice: "#{@location.name} created. Print the poster below."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def poster
    @location = current_organisation.locations.find(params[:id])
    @qr_svg = RQRCode::QRCode.new(sign_in_location_url(@location.slug, host: request.host_with_port))
      .as_svg(offset: 0, color: "000", shape_rendering: "crispEdges", module_size: 8, standalone: true)
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end
end
