class UsersController < ApplicationController
  before_action :require_super_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :load_form_collections, only: [:new, :create, :edit, :update]

  def index
    @users = User
      .includes(:department, :unit)
      .order(:full_name)
      .page(params[:page])
      .per(15)
  end

  def show
  end

  def new
    @user = User.new(active: true)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      AuditLogger.call(
        user: current_user,
        action: "create",
        auditable: @user,
        description: "Created user #{@user.email}"
      )

      redirect_to @user, success: "User created successfully."
    else
      flash.now[:error] = "Unable to create user."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    permitted = user_params.dup

    if permitted[:password].blank?
      permitted.delete(:password)
      permitted.delete(:password_confirmation)
    end

    if @user.update(permitted)
      AuditLogger.call(
        user: current_user,
        action: "update",
        auditable: @user,
        description: "Updated user #{@user.email}"
      )

      redirect_to @user, success: "User updated successfully."
    else
      flash.now[:error] = "Unable to update user."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, error: "You cannot deactivate your own account."
      return
    end

    if @user.update(active: false)
      AuditLogger.call(
        user: current_user,
        action: "deactivate",
        auditable: @user,
        description: "Deactivated user #{@user.email}"
      )

      redirect_to users_path, success: "User was deactivated successfully."
    else
      redirect_to users_path, error: "User could not be deactivated."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def load_form_collections
    @departments = Department.order(:name)
    @units = Unit.includes(:department).order(:name)
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email,
      :phone_number,
      :role,
      :department_id,
      :unit_id,
      :active,
      :requires_duty_session,
      :email_notifications_enabled,
      :sms_notifications_enabled,
      :password,
      :password_confirmation
    )
  end
end