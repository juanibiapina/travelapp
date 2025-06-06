class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    head :not_found
  end

  def after_sign_in_path_for(resource)
    if session[:pending_invite_token]
      token = session.delete(:pending_invite_token)
      invite = Invite.find_by(token: token)

      if invite && invite.invite_valid? && !invite.trip.member?(resource)
        if invite.trip.add_member(resource)
          flash[:notice] = "Successfully joined the trip!"
          return trip_path(invite.trip)
        end
      end
    end

    # Default behavior
    super
  end
end
