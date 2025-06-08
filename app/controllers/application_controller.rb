class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    head :not_found
  end

  # Override current_user to work with Account-based authentication
  def current_user
    current_account&.user
  end
  helper_method :current_user

  # Override user_signed_in? to work with Account-based authentication
  def user_signed_in?
    account_signed_in?
  end
  helper_method :user_signed_in?

  def after_sign_in_path_for(resource)
    if session[:pending_invite_token]
      token = session.delete(:pending_invite_token)
      invite = Invite.find_by(token: token)

      # resource is now an Account, we need the User
      user = resource.is_a?(Account) ? resource.user : resource

      if invite && invite.invite_valid? && !invite.trip.member?(user)
        if invite.trip.add_member(user)
          flash[:notice] = "Successfully joined the trip!"
          return trip_path(invite.trip)
        end
      end
    end

    # Default behavior
    super
  end
end
