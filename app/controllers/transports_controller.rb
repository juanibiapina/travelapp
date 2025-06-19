class TransportsController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip
  before_action :set_transport, only: %i[ show edit update destroy ]

  # GET /trips/1/transports or /trips/1/transports.json
  def index
    # Authorization is handled in set_trip
    @transports = @trip.transports.includes(:origin_place, :destination_place, :users)
  end

  # GET /trips/1/transports/1 or /trips/1/transports/1.json
  def show
    authorize @transport
  end

  # GET /trips/1/transports/new
  def new
    @transport = @trip.transports.build
    @places = @trip.places.order(:name)
    authorize @transport
  end

  # GET /trips/1/transports/1/edit
  def edit
    @places = @trip.places.order(:name)
    authorize @transport
  end

  # POST /trips/1/transports or /trips/1/transports.json
  def create
    @transport = @trip.transports.build(transport_params)
    authorize @transport

    respond_to do |format|
      if @transport.save
        format.html { redirect_to trip_transports_path(@trip), notice: "Transport was successfully created." }
        format.json { render :show, status: :created, location: [ @trip, @transport ] }
      else
        @places = @trip.places.order(:name)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transport.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1/transports/1 or /trips/1/transports/1.json
  def update
    authorize @transport

    respond_to do |format|
      if @transport.update(transport_params)
        format.html { redirect_to [ @trip, @transport ], notice: "Transport was successfully updated." }
        format.json { render :show, status: :ok, location: [ @trip, @transport ] }
      else
        @places = @trip.places.order(:name)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transport.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1/transports/1 or /trips/1/transports/1.json
  def destroy
    authorize @transport
    @transport.destroy!

    respond_to do |format|
      format.html { redirect_to trip_transports_path(@trip), status: :see_other, notice: "Transport was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params.expect(:trip_id))
      authorize @trip, :show?
    end

    def set_transport
      @transport = @trip.transports.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def transport_params
      params.expect(transport: [ :name, :start_date, :end_date, :origin_place_id, :destination_place_id, user_ids: [] ])
    end
end
