class MinutesController < ApplicationController
  before_action :require_admin_access!
  before_action :set_minute, only: [:show, :process_minutes]

  def index
    @minutes = Minute
      .includes(:created_by)
      .order(created_at: :desc)
      .page(params[:page])
      .per(15)
  end

  def show
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
      redirect_to @minute, success: "Audio uploaded successfully. You can now start extraction."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def process_minutes
    if rate_limited?
      redirect_to @minute, warning: "Please wait before starting another extraction."
      return
    end

    if @minute.processing?
      redirect_to @minute, warning: "Minutes are already being processed."
      return
    end

    if @minute.completed?
      redirect_to @minute, warning: "Minutes have already been extracted."
      return
    end

    @minute.update!(status: :processing)

    ProcessMinuteJob.perform_later(@minute.id)

    redirect_to @minute, success: "Minutes extraction started. This page will refresh automatically."
  end

  private

  def set_minute
    @minute = Minute.find(params[:id])
  end

  def minute_params
    params.require(:minute).permit(:title, :audio_file)
  end

  def rate_limited?
    key = "minutes_extraction:user:#{current_user.id}"

    if Rails.cache.read(key)
      true
    else
      Rails.cache.write(key, true, expires_in: 2.minutes)
      false
    end
  end
end