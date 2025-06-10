class TripsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip, only: %i[ show edit update destroy members timeline map ]

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
    @memberships = @trip.trip_memberships.includes(:user)
  end

  # GET /trips/1/timeline
  def timeline
    authorize @trip, :show?
    @trip_events = @trip.trip_events.order(:start_date)
    @selected_date = params[:date]&.to_date || @trip.start_date
    @selected_events = @trip_events.select do |event|
      @selected_date >= event.start_date && @selected_date <= event.end_date
    end
  end

  # GET /trips/1/map
  def map
    authorize @trip, :show?
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def trip_params
      params.expect(trip: [ :name, :start_date, :end_date ])
    end
end
