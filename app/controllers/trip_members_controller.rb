class TripMembersController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip
  before_action :set_trip_member, only: [ :edit, :update, :destroy ]

  # GET /trips/:trip_id/trip_members/new
  def new
    authorize @trip, :update?
    @trip_member = User.new
  end

  # POST /trips/:trip_id/trip_members
  def create
    authorize @trip, :update?
    @trip_member = User.new(trip_member_params)

    if @trip_member.save
      @trip.trip_memberships.create!(user: @trip_member, role: "member")
      redirect_to members_trip_path(@trip), notice: "Trip member was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /trips/:trip_id/trip_members/:id/edit
  def edit
    authorize @trip, :update?
  end

  # PATCH/PUT /trips/:trip_id/trip_members/:id
  def update
    authorize @trip, :update?

    if @trip_member.update(trip_member_params)
      redirect_to members_trip_path(@trip), notice: "Trip member was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /trips/:trip_id/trip_members/:id
  def destroy
    authorize @trip, :update?

    # Don't allow deleting the owner
    membership = @trip.trip_memberships.find_by(user: @trip_member)
    if membership&.owner?
      redirect_to members_trip_path(@trip), alert: "Cannot remove the trip owner."
      return
    end

    # Remove the membership and delete the user if they have no account
    membership&.destroy
    @trip_member.destroy if @trip_member.account.nil?

    redirect_to members_trip_path(@trip), notice: "Trip member was successfully removed."
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  end

  def set_trip_member
    @trip_member = User.find(params[:id])
  end

  def trip_member_params
    params.require(:user).permit(:name, :picture)
  end
end
