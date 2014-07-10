module CreditsApi
  class ApplicationController < ActionController::Base
    protect_from_forgery
    respond_to :json

    def render_json obj
      render json: obj
    end

    def render_ok
      render nothing: true, status: 200
    end

    def render_bad_request 
      render nothing: true, status: 403
    end
  end
end
