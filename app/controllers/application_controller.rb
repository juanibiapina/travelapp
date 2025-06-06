class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Handle pending invites after login
  before_action :handle_pending_invite, if: :user_signed_in?

  private

  def user_not_authorized
    head :not_found
  end

  def handle_pending_invite
    return unless session[:pending_invite_token]

    token = session.delete(:pending_invite_token)
    invite = Invite.find_by(token: token)

    if invite && invite.invite_valid? && !invite.trip.member?(current_user)
      if invite.trip.add_member(current_user)
        redirect_to invite.trip, notice: "Successfully joined the trip!"
        nil
      end
    end
  end
end
