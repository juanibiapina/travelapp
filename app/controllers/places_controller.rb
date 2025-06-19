class PlacesController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip
  before_action :set_place, only: %i[ show edit update destroy ]

  # GET /trips/1/places or /trips/1/places.json
  def index
    # Authorization is handled in set_trip
    @places = @trip.places
  end

  # GET /trips/1/places/1 or /trips/1/places/1.json
  def show
    authorize @place
  end

  # GET /trips/1/places/new
  def new
    @place = @trip.places.build
    authorize @place
  end

  # GET /trips/1/places/1/edit
  def edit
    authorize @place
  end

  # POST /trips/1/places or /trips/1/places.json
  def create
    @place = @trip.places.build(place_params)
    authorize @place

    respond_to do |format|
      if @place.save
        format.html { redirect_to trip_places_path(@trip), notice: "Place was successfully created." }
        format.json { render :show, status: :created, location: [ @trip, @place ] }
      else
        format.html { redirect_to trip_places_path(@trip), alert: "Error: #{@place.errors.full_messages.join(', ')}" }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1/places/1 or /trips/1/places/1.json
  def update
    authorize @place

    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to [ @trip, @place ], notice: "Place was successfully updated." }
        format.json { render :show, status: :ok, location: [ @trip, @place ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1/places/1 or /trips/1/places/1.json
  def destroy
    authorize @place
    @place.destroy!

    respond_to do |format|
      format.html { redirect_to trip_places_path(@trip), status: :see_other, notice: "Place was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params.expect(:trip_id))
      authorize @trip, :show?
    end

    def set_place
      @place = @trip.places.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def place_params
      params.expect(place: [ :name, :start_date, :end_date ])
    end
end
