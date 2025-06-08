class InvitesController < ApplicationController
  before_action :authenticate_account!, except: [ :accept ]
  before_action :set_trip, only: [ :create, :destroy ]
  before_action :set_invite, only: [ :destroy ]

  def create
    authorize @trip, :show? # User must be able to see the trip
    authorize @trip, :update? # User must be able to update the trip (only owners)

    @invite = @trip.invites.build(created_by: current_user)

    if @invite.save
      redirect_to @trip, notice: "Invite link created successfully!"
    else
      redirect_to @trip, alert: "Failed to create invite link: #{@invite.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    authorize @trip, :update? # Only trip owners can revoke invites

    @invite.revoke!
    redirect_to @trip, notice: "Invite link revoked successfully."
  end

  def accept
    @invite = Invite.find_by(token: params[:token])

    unless @invite
      redirect_to root_path, alert: "Invalid invite link."
      return
    end

    unless @invite.invite_valid?
      redirect_to root_path, alert: "This invite link has expired or been revoked."
      return
    end

    unless user_signed_in?
      # Store the invite token in session and redirect to sign in
      session[:pending_invite_token] = params[:token]
      redirect_to new_user_session_path, notice: "Please sign in to join this trip."
      return
    end

    # User is signed in, try to add them to the trip
    if @invite.trip.member?(current_user)
      redirect_to @invite.trip, notice: "You are already a member of this trip."
    else
      if @invite.trip.add_member(current_user)
        redirect_to @invite.trip, notice: "Successfully joined the trip!"
      else
        redirect_to root_path, alert: "Failed to join the trip."
      end
    end
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  end

  def set_invite
    @invite = @trip.invites.find(params[:id])
  end
end
