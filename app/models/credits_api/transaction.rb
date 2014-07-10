require "ext/active_record/advisory_lock.rb"

module CreditsApi
  class Transaction < ActiveRecord::Base
    include ActiveRecord::AdvisoryLock

    users        = CreditsApi.user_class.model_name.plural.intern #:users
    transactions = self.model_name.plural.intern #:credits_api_transactions

    belongs_to users
    CreditsApi.user_class.has_many transactions, dependent: :destroy

    def self.deposit user_id, amount
      self.add user_id, amount
    end

    def self.withdraw user_id, amount
      self.add user_id, -amount
    end

    def self.users
      result = []
      klass, name_attr = CreditsApi.user_class, CreditsApi.name_attr
      # TODO refactor with join
      klass.order(name_attr => :asc).
        select("id, #{name_attr}").
        all.
        each do |user|
          balance = self.user_balance user.id
          result<< { name: user.name, balance: balance }
        end
      result
    end

    def self.statement user_id
      self.where(user_id: user_id).
        select("created_at, amount, balance").
        order(created_at: :asc).
        all.
        map{|e| {
            created_at: e.created_at,
            balance:    e.balance,
            amount:     e.amount
          }
        }
    end

    def self.add user_id, amount
      self.obtain_advisory_lock(user_id) do
        balance = self.user_balance(user_id) + amount
        self.create! user_id: user_id, amount: amount, balance: balance 
      end
    end

    def self.user_balance user_id
      last = self.where(user_id: user_id).
        select("balance").
        order(created_at: :desc).
        first.
        try(:balance) || 0.0
    end
  end
end
