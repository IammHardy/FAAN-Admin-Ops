class MinutesController < ApplicationController
  before_action :require_admin_access!
  before_action :set_minute, only: [:show, :process_minutes]

  def index
    @minutes = Minute.includes(:created_by).order(created_at: :desc)
  end

  def show
  @minute = Minute.find(params[:id])

  respond_to do |format|
    format.html
    format.pdf do
      render pdf: "minute_#{@minute.id}",
             template: "minutes/show",
             layout: "pdf"
    end
  end
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
  if @minute.processing?
    redirect_to @minute, alert: "Minutes are already being processed."
    return
  end

  ProcessMinuteJob.perform_later(@minute.id)

  redirect_to @minute, notice: "Minutes processing started. Check back shortly."
end
  private

  def set_minute
    @minute = Minute.find(params[:id])
  end

  def minute_params
    params.require(:minute).permit(:title, :audio_file)
  end
end