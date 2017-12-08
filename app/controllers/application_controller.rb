class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :reset_session
  before_filter :authenticate_employee!

  before_filter :set_current_employee
  before_filter :logout_if_disable
  before_filter :verify_current_company
  alias_method :current_user, :current_employee

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  rescue_from ActionController::RedirectBackError do |exception|
    redirect_to root_url, :alert => "Page not found."
  end

  rescue_from ActionController::UnknownFormat do |exception|
    redirect_to root_url, :alert => "Invalid Request."
  end

  def default_url_options
    (current_employee && !current_employee.has_role?(:super_admin)) ? { :current_company => current_company.permalink } : {}
  end

  def verify_current_company
    if current_employee && !current_employee.has_role?(:super_admin)
      redirect_to root_path if params[:current_company].to_s != current_company.permalink
    end
  end

  def logout_if_disable
    if current_employee && !current_employee.has_role?(:super_admin)
      destroy_employee_session_path if (current_employee.disabled? || current_employee.company.disabled?)
    end
  end

  def current_company
    current_employee.company if current_employee 
  end

  def set_current_employee
    Thread.current[:audited_admin] = current_employee
    Thread.current[:ip] = request.try(:ip) 
  end

end
