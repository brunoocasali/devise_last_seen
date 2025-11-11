# frozen_string_literal: true

class ProductsController < ActionController::API
  include DeviseLastSeen::Controllers

  def index
    render json: { message: 'Hello, world!' }
  end
end
