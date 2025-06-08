class TripMembersController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip
  before_action :set_member, only: [ :edit, :update, :destroy ]

  # GET /trips/1/members/new
  def new
    authorize @trip, :update? # Only trip owners can add members
    @member = User.new
  end

  # POST /trips/1/members
  def create
    authorize @trip, :update? # Only trip owners can add members
    @member = User.new(member_params)

    if @member.save
      @trip.add_member(@member, role: "member")
      redirect_to @trip, notice: "Member was successfully added to the trip."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /trips/1/members/1/edit
  def edit
    authorize @trip, :update? # Only trip owners can edit members
  end

  # PATCH/PUT /trips/1/members/1
  def update
    authorize @trip, :update? # Only trip owners can update members

    if @member.update(member_params)
      redirect_to @trip, notice: "Member was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /trips/1/members/1
  def destroy
    authorize @trip, :update? # Only trip owners can remove members

    # Don't allow removing the trip owner
    membership = @trip.trip_memberships.find_by(user: @member)
    if membership&.owner?
      redirect_to @trip, alert: "Cannot remove the trip owner."
    else
      membership&.destroy
      # Only destroy the user if they have no other trip memberships and no account
      if @member.trip_memberships.empty? && !@member.account?
        @member.destroy
      end
      redirect_to @trip, notice: "Member was successfully removed from the trip."
    end
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
    authorize @trip, :show? # User must be able to see the trip
  end

  def set_member
    @member = User.find(params[:id])
    # Ensure the member belongs to this trip
    unless @trip.member?(@member)
      redirect_to @trip, alert: "Member not found in this trip."
    end
  end

  def member_params
    params.require(:user).permit(:name, :picture)
  end
end
