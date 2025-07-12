class ApplicationController < ActionController::API
  protected

  def render_error(message, status = :bad_request)
    render json: { error: message }, status: status
  end

  def render_not_found(message = "Resource not found")
    render json: { error: message }, status: :not_found
  end

  def render_server_error(message = "Internal server error")
    render json: { error: message }, status: :internal_server_error
  end
end
