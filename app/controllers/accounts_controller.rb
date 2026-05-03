class AccountsController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if password_fields_blank?
      if @user.update(account_params_without_password)
        redirect_to edit_account_path, success: "Account updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.update_with_password(account_params)
        bypass_sign_in(@user)
        redirect_to edit_account_path, success: "Password updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def account_params
    params.require(:user).permit(
      :full_name,
      :email,
      :current_password,
      :password,
      :password_confirmation
    )
  end

  def account_params_without_password
    params.require(:user).permit(:full_name, :email)
  end

  def password_fields_blank?
    params[:user][:password].blank? &&
      params[:user][:password_confirmation].blank? &&
      params[:user][:current_password].blank?
  end
end