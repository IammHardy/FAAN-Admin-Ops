class LogEntriesController < ApplicationController
  before_action :set_log_report
  before_action :set_log_entry, only: [:edit, :update, :destroy]

  def create
    @log_entry = @log_report.log_entries.build(log_entry_params)

    if @log_entry.save
      redirect_to @log_report, success: "Log entry added successfully."
    else
      redirect_to @log_report, error: @log_entry.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @log_entry.update(log_entry_params)
      redirect_to @log_report, success: "Log entry updated successfully."
    else
      flash.now[:error] = "Unable to update log entry."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @log_entry.destroy
    redirect_to @log_report, success: "Log entry deleted successfully."
  end

  private

  def set_log_report
    @log_report = LogReport.find(params[:log_report_id])
  end

  def set_log_entry
    @log_entry = @log_report.log_entries.find(params[:id])
  end

  def log_entry_params
    params.require(:log_entry).permit(
      :entry_time,
      :description,
      :incident_flag,
      :action_taken,
      :follow_up_needed
    )
  end
end