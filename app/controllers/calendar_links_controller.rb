class CalendarLinksController < ApplicationController
  before_action :set_calendar_link, only: %i[edit update destroy]

  # GET /calendar_links
  def index
    @calendar_links = @current_user.calendar_links
  end

  # GET /calendar_links/new
  def new
    @calendar_link = CalendarLink.new
  end

  # GET /calendar_links/1/edit
  def edit
  end

  # POST /calendar_links
  def create
    @calendar_link = CalendarLink.new(calendar_link_params.merge(user: @current_user))

    if @calendar_link.save
      redirect_to calendar_links_path, notice: "Calendar link was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /calendar_links/1
  def update
    if @calendar_link.update(calendar_link_params)
      redirect_to calendar_links_path, notice: "Calendar link was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /calendar_links/1
  def destroy
    @calendar_link.destroy
    redirect_to calendar_links_path, notice: "Calendar link was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_calendar_link
    @calendar_link = CalendarLink.find_by(id: params[:id], user_id: @current_user.id)
  end

  # Only allow a list of trusted parameters through.
  def calendar_link_params
    params.require(:calendar_link).permit(:link_name, :link_url)
  end
end
