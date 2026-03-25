class UnitsController < ApplicationController
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  before_action :load_departments, only: [:new, :create, :edit, :update]

  def index
    @units = Unit.includes(:department).order(:name)
  end

  def show
  end

  def new
    @unit = Unit.new
  end

  def create
    @unit = Unit.new(unit_params)

    if @unit.save
      redirect_to @unit, success: "Unit created successfully."
    else
      flash.now[:error] = "Unable to create unit."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @unit.update(unit_params)
      redirect_to @unit, success: "Unit updated successfully."
    else
      flash.now[:error] = "Unable to update unit."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @unit.destroy
    redirect_to units_path, success: "Unit deleted successfully."
  rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::InvalidForeignKey
    redirect_to units_path, error: "Unit cannot be deleted because it is being used."
  end

  private

  def set_unit
    @unit = Unit.find(params[:id])
  end

  def load_departments
    @departments = Department.order(:name)
  end

  def unit_params
    params.require(:unit).permit(:department_id, :name, :description, :active)
  end
end