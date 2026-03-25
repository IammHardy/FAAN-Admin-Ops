class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  def index
    @departments = Department.order(:name)
  end

  def show
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(department_params)

    if @department.save
      redirect_to @department, success: "Department created successfully."
    else
      flash.now[:error] = "Unable to create department."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @department.update(department_params)
      redirect_to @department, success: "Department updated successfully."
    else
      flash.now[:error] = "Unable to update department."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @department.destroy
    redirect_to departments_path, success: "Department deleted successfully."
  rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::InvalidForeignKey
    redirect_to departments_path, error: "Department cannot be deleted because it is being used."
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :description, :active)
  end
end