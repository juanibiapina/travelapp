class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_link, only: %i[ show edit update destroy ]

  # GET /trips/1/links or /trips/1/links.json
  def index
    @links = @trip.links
  end

  # GET /trips/1/links/1 or /trips/1/links/1.json
  def show
  end

  # GET /trips/1/links/new
  def new
    @link = @trip.links.build
  end

  # GET /trips/1/links/1/edit
  def edit
  end

  # POST /trips/1/links or /trips/1/links.json
  def create
    @link = @trip.links.build(link_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to @trip, notice: "Link was successfully created." }
        format.json { render :show, status: :created, location: [ @trip, @link ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1/links/1 or /trips/1/links/1.json
  def update
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
    @link.destroy!

    respond_to do |format|
      format.html { redirect_to @trip, status: :see_other, notice: "Link was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trip
      @trip = current_user.trips.find(params.expect(:trip_id))
    end

    def set_link
      @link = @trip.links.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def link_params
      params.expect(link: [ :url ])
    end
end
