# app/controllers/records_controller.rb

class RecordsController < ApplicationController
  before_action :require_active_duty_session!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :set_record, only: [:show, :edit, :update, :destroy]
  

  def index
    @records = Record.search(params)
                     .includes(:filed_by)
                     .recent
                     .page(params[:page])
                     .per(15)
  end

  def show
  end

  def new
    @record = Record.new(filed_date: Date.current)
  end

  def create
    @record = Record.new(record_params)
    @record.filed_by = current_user
    @record.duty_session = current_duty_session

    if @record.save
      redirect_to @record, notice: "Record was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @record.update(record_params)
      redirect_to @record, notice: "Record was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @record.destroy
    redirect_to records_path, notice: "Record was successfully deleted."
  end

  def daily_log
    @selected_date = params[:filed_date].presence || Date.current.to_s

    @records = Record.where(filed_date: @selected_date)
                     .includes(:filed_by)
                     .order(:category, :title)
  end

  private

  def set_record
    @record = Record.find(params[:id])
  end

  def record_params
    params.require(:record).permit(
      :title,
      :category,
      :document_date,
      :filed_date,
      :signed_by,
      :recipient_or_source,
      :reference_number,
      :physical_location,
      :notes,
      :attachment,
      :operation_staff_id,
    )
  end
end