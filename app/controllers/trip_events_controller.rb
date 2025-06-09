class TripEventsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip
  before_action :set_trip_event, only: %i[ show edit update destroy ]

  # GET /trips/1/trip_events or /trips/1/trip_events.json
  def index
    # Authorization is handled in set_trip
    @trip_events = @trip.trip_events.order(:start_date)
  end

  # GET /trips/1/trip_events/1 or /trips/1/trip_events/1.json
  def show
    authorize @trip_event
  end

  # GET /trips/1/trip_events/new
  def new
    @trip_event = @trip.trip_events.build
    authorize @trip_event
  end

  # GET /trips/1/trip_events/1/edit
  def edit
    authorize @trip_event
  end

  # POST /trips/1/trip_events or /trips/1/trip_events.json
  def create
    @trip_event = @trip.trip_events.build(trip_event_params)
    authorize @trip_event

    respond_to do |format|
      if @trip_event.save
        format.html { redirect_to trip_trip_events_path(@trip), notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: [ @trip, @trip_event ] }
      else
        format.html { redirect_to trip_trip_events_path(@trip), alert: "Error: #{@trip_event.errors.full_messages.join(', ')}" }
        format.json { render json: @trip_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1/trip_events/1 or /trips/1/trip_events/1.json
  def update
    authorize @trip_event

    respond_to do |format|
      if @trip_event.update(trip_event_params)
        format.html { redirect_to [ @trip, @trip_event ], notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: [ @trip, @trip_event ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @trip_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1/trip_events/1 or /trips/1/trip_events/1.json
  def destroy
    authorize @trip_event
    @trip_event.destroy!

    respond_to do |format|
      format.html { redirect_to trip_trip_events_path(@trip), status: :see_other, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params.expect(:trip_id))
      authorize @trip, :show?
    end

    def set_trip_event
      @trip_event = @trip.trip_events.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def trip_event_params
      params.expect(trip_event: [ :title, :start_date, :end_date ])
    end
end
