require_dependency "credits_api/application_controller"
require_dependency "credits_api/utils"

module CreditsApi
  class UsersController < ApplicationController
    before_filter :check_id,     only: [:deposit, :withdraw, :statement]
    before_filter :check_amount, only: [:deposit, :withdraw]
    
    def deposit
      Transaction.deposit @id, @amount
      render_ok
    end

    def withdraw
      Transaction.withdraw @id, @amount
      render_ok
    end

    def index
      @users = Transaction.users
      render_json @users #, only: [:name, :balance]
    end

    def statement 
      @transactions = Transaction.statement @id
      render_json @transactions #, only: [:created_at, :amount, :balance]
    end

    protected

    def check_amount
      @amount = Utils.cast_float params[:amount]
      render_bad_request unless (@amount && @amount > 0.0)
    end

    def check_id
      @id = CreditsApi.check_id params[:id]
      render_bad_request unless @id
    end
  end
end
