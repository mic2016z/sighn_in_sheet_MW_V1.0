class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Single-organisation MVP: no accounts, no login. Multi-tenant login can be
  # layered back in before a shared deploy serves more than one org.
  def current_organisation
    @current_organisation ||= Organisation.first!
  end
  helper_method :current_organisation
end
