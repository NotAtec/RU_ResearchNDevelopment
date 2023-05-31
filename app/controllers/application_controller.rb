class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])

    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])

    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  private

  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to welcome_path, notice: "Please Login or Sign Up to Play the Game!"
    end
  end
end
