class OperationStaffsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_super_admin!, only: [:archived, :restore]
  before_action :require_active_duty_session!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_operation_staff,
                only: [:show, :edit, :update, :destroy, :restore]

  def index
    @operation_staffs = OperationStaff
      .active_folders
      .search(params)
      .alphabetical
      .page(params[:page])
      .per(15)
  end

  def archived
    @operation_staffs = OperationStaff
      .archived_folders
      .alphabetical
      .page(params[:page])
      .per(15)
  end

  def show
    @records = Record.active.search(
      params.merge(operation_staff_id: @operation_staff.id)
    )
    .includes(:filed_by)
    .recent
    .page(params[:page])
    .per(15)
  end

  def new
    @operation_staff = OperationStaff.new
    @record = Record.new(
      filed_date: Date.current,
      operation_staff_id: params[:operation_staff_id]
    )
  end

  def create
    @operation_staff = OperationStaff.new(operation_staff_params)

    if @operation_staff.save
      AuditLogger.call(
        user: current_user,
        action: "create",
        auditable: @operation_staff,
        description: "Created staff folder #{@operation_staff.full_name}"
      )

      redirect_to @operation_staff,
                  notice: "Staff created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @operation_staff.update(operation_staff_params)
      AuditLogger.call(
        user: current_user,
        action: "update",
        auditable: @operation_staff,
        description: "Updated staff folder #{@operation_staff.full_name}"
      )

      redirect_to @operation_staff,
                  notice: "Staff updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @operation_staff.archive!(
      current_user,
      reason: params[:archive_reason],
      status: params[:folder_status].presence || "archived"
    )

    AuditLogger.call(
      user: current_user,
      action: "archive",
      auditable: @operation_staff,
      description: "Archived staff folder #{@operation_staff.full_name}"
    )

    redirect_to operation_staffs_path,
                notice: "Staff folder archived successfully."
  end

  def restore
    @operation_staff.restore!

    AuditLogger.call(
      user: current_user,
      action: "restore",
      auditable: @operation_staff,
      description: "Restored staff folder #{@operation_staff.full_name}"
    )

    redirect_to @operation_staff,
                notice: "Staff folder restored successfully."
  end

  private

  def set_operation_staff
    @operation_staff = OperationStaff.find(params[:id])
  end

  def operation_staff_params
    params.require(:operation_staff).permit(
      :full_name,
      :staff_number,
      :designation,
      :unit,
      :phone_number,
      :email,
      :employment_status,
      :physical_folder_location,
      :notes,
      :can_be_on_duty,
      :duty_area,
      :always_present,
      :folder_status,
      :archive_reason
    )
  end
end