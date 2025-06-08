class LinksController < ApplicationController
  before_action :authenticate_account!
  before_action :set_trip
  before_action :set_link, only: %i[ show edit update destroy ]

  # GET /trips/1/links or /trips/1/links.json
  def index
    # Authorization is handled in set_trip
    @links = @trip.links
  end

  # GET /trips/1/links/1 or /trips/1/links/1.json
  def show
    authorize @link
  end

  # GET /trips/1/links/new
  def new
    @link = @trip.links.build
    authorize @link
  end

  # GET /trips/1/links/1/edit
  def edit
    authorize @link
  end

  # POST /trips/1/links or /trips/1/links.json
  def create
    @link = @trip.links.build(link_params)
    authorize @link

    respond_to do |format|
      if @link.save
        format.html { redirect_to trip_links_path(@trip), notice: "Link was successfully created." }
        format.json { render :show, status: :created, location: [ @trip, @link ] }
      else
        format.html { redirect_to trip_links_path(@trip), alert: "Error: #{@link.errors.full_messages.join(', ')}" }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1/links/1 or /trips/1/links/1.json
  def update
    authorize @link

    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to [ @trip, @link ], notice: "Link was successfully updated." }
        format.json { render :show, status: :ok, location: [ @trip, @link ] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1/links/1 or /trips/1/links/1.json
  def destroy
    authorize @link
    @link.destroy!

    respond_to do |format|
      format.html { redirect_to trip_links_path(@trip), status: :see_other, notice: "Link was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = Trip.find(params.expect(:trip_id))
      authorize @trip, :show?
    end

    def set_link
      @link = @trip.links.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def link_params
      params.expect(link: [ :url ])
    end
end
