class TripsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip, only: %i[ show edit update destroy members update_member_starting_place create_guest_member update_guest_member destroy_guest_member ]

  # GET /trips or /trips.json
  def index
    @trips = policy_scope(Trip)
  end

  # GET /trips/1 or /trips/1.json
  def show
    authorize @trip
  end

  # GET /trips/1/members
  def members
    authorize @trip, :show?
    @memberships = @trip.trip_memberships.includes(:user, :starting_place)
    @places = @trip.places.order(:name)
  end

  # GET /trips/new
  def new
    @trip = Trip.new
    authorize @trip
  end

  # GET /trips/1/edit
  def edit
    authorize @trip
  end

  # POST /trips or /trips.json
  def create
    @trip = Trip.new(trip_params)
    authorize @trip

    respond_to do |format|
      if @trip.save
        # Create the ownership membership
        @trip.trip_memberships.create!(user: current_user, role: "owner")
        format.html { redirect_to @trip, notice: "Trip was successfully created." }
        format.json { render :show, status: :created, location: @trip }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1 or /trips/1.json
  def update
    authorize @trip

    respond_to do |format|
      if @trip.update(trip_params)
        format.html { redirect_to @trip, notice: "Trip was successfully updated." }
        format.json { render :show, status: :ok, location: @trip }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1 or /trips/1.json
  def destroy
    authorize @trip
    @trip.destroy!

    respond_to do |format|
      format.html { redirect_to trips_path, status: :see_other, notice: "Trip was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # PATCH /trips/1/update_member_starting_place
  def update_member_starting_place
    authorize @trip, :show?
    membership = @trip.trip_memberships.find(params[:membership_id])

    if params[:starting_place_id].present?
      place = @trip.places.find(params[:starting_place_id])
      membership.update!(starting_place: place)
    else
      membership.update!(starting_place: nil)
    end

    redirect_to members_trip_path(@trip), notice: "Starting place updated successfully."
  end

  # POST /trips/1/create_guest_member
  def create_guest_member
    authorize @trip, :update? # Only trip owners can add members

    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        @trip.add_member(@user, role: "member")
        format.html { redirect_to members_trip_path(@trip), notice: "Member added successfully." }
      else
        # Set up instance variables needed by the members view
        @memberships = @trip.trip_memberships.includes(:user, :starting_place)
        @places = @trip.places.order(:name)
        format.html { render :members, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /trips/1/update_guest_member
  def update_guest_member
    authorize @trip, :update? # Only trip owners can update members
    membership = @trip.trip_memberships.find(params[:membership_id])

    # Only allow updating users without accounts
    if membership.user.account.present?
      redirect_to members_trip_path(@trip), alert: "Cannot update members with accounts."
      return
    end

    if membership.user.update(user_params)
      redirect_to members_trip_path(@trip), notice: "Member updated successfully."
    else
      redirect_to members_trip_path(@trip), alert: "Failed to update member: #{membership.user.errors.full_messages.join(', ')}"
    end
  end

  # DELETE /trips/1/destroy_guest_member
  def destroy_guest_member
    authorize @trip, :update? # Only trip owners can remove members
    membership = @trip.trip_memberships.find(params[:membership_id])

    # Only allow deleting users without accounts
    unless membership.user.account.nil?
      render status: :unprocessable_entity, plain: "Cannot delete members with accounts"
      return
    end

    user = membership.user
    membership.destroy!
    user.destroy! # Delete the user since they have no account

    redirect_to members_trip_path(@trip), notice: "Member removed successfully."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def trip_params
      params.expect(trip: [ :name, :start_date, :end_date ])
    end

    def user_params
      params.expect(user: [ :name, :picture ])
    end
end
