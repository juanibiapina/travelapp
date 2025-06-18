class AccommodationsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip
  before_action :set_accommodation, only: %i[ show edit update destroy ]

  # GET /trips/1/accommodations or /trips/1/accommodations.json
  def index
    # Authorization is handled in set_trip
    @accommodations = @trip.accommodations.joins(:place).order(:start_date, "places.name")
  end

  # GET /trips/1/accommodations/1 or /trips/1/accommodations/1.json
  def show
    authorize @accommodation
  end

  # GET /trips/1/accommodations/new
  def new
    @accommodation = Accommodation.new
    @places = @trip.places.order(:name)
    authorize @accommodation
  end

  # GET /trips/1/accommodations/1/edit
  def edit
    @places = @trip.places.order(:name)
    authorize @accommodation
  end

  # POST /trips/1/accommodations or /trips/1/accommodations.json
  def create
    @accommodation = Accommodation.new(accommodation_params)
    authorize @accommodation

    respond_to do |format|
      if @accommodation.save
        format.html { redirect_to trip_accommodations_path(@trip), notice: "Accommodation was successfully created." }
        format.json { render :show, status: :created, location: [ @trip, @accommodation ] }
      else
        @places = @trip.places.order(:name)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @accommodation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1/accommodations/1 or /trips/1/accommodations/1.json
  def update
    authorize @accommodation

    respond_to do |format|
      if @accommodation.update(accommodation_params)
        format.html { redirect_to [ @trip, @accommodation ], notice: "Accommodation was successfully updated." }
        format.json { render :show, status: :ok, location: [ @trip, @accommodation ] }
      else
        @places = @trip.places.order(:name)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @accommodation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1/accommodations/1 or /trips/1/accommodations/1.json
  def destroy
    authorize @accommodation
    @accommodation.destroy!

    respond_to do |format|
      format.html { redirect_to trip_accommodations_path(@trip), status: :see_other, notice: "Accommodation was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params.expect(:trip_id))
      authorize @trip, :show?
    end

    def set_accommodation
      @accommodation = @trip.accommodations.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def accommodation_params
      params.expect(accommodation: [ :title, :start_date, :end_date, :place_id ]).tap do |permitted|
        # Ensure the place belongs to the current trip
        if permitted[:place_id].present?
          place = @trip.places.find_by(id: permitted[:place_id])
          raise ActionController::ParameterMissing, "place_id must belong to the current trip" unless place
        end
      end
    end
end
