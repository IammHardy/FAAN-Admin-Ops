class MinutesController < ApplicationController
  before_action :set_minute, only: [:show, :process_minutes]

  def index
    @minutes = Minute.includes(:created_by).order(created_at: :desc)
  end

  def show
  end

  def new
    @minute = Minute.new
  end

  def create
    @minute = Minute.new(minute_params)
    @minute.created_by = current_user
    @minute.status = :pending

    if @minute.save
      redirect_to @minute, success: "Audio uploaded successfully. Minutes extraction will be processed next."
    else
      render :new, status: :unprocessable_entity
    end
  end
def process_minutes
  MinutesExtractionService.new(@minute).call

  redirect_to @minute, success: "Minutes extracted successfully."
rescue StandardError => e
  redirect_to @minute, error: "Extraction failed: #{e.message}"
end
  private

  def set_minute
    @minute = Minute.find(params[:id])
  end

  def minute_params
    params.require(:minute).permit(:title, :audio_file)
  end
end