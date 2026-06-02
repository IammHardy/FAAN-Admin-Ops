class OperationStaffsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_operation_staff,
                only: [:show, :edit, :update, :destroy]

  def index
    @operation_staffs = OperationStaff
                          .alphabetical
                          .page(params[:page])
                          .per(15)
  end

 def show
  @records = Record.search(
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
      redirect_to @operation_staff,
                  notice: "Staff updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @operation_staff.destroy

    redirect_to operation_staffs_path,
                notice: "Staff deleted successfully."
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
      :can_be_on_duty
      :duty_area,
      :always_present
    )
  end
end