require "rails_helper"

RSpec.describe CreditsApi::Transaction, :type => :model do

  let!(:user1) { create(:user1) }
  let!(:user2) { create(:user2) }
  let!(:user3) { create(:user3) }
  let!(:user4) { create(:user4) }

  before :all do
    CreditsApi.user_class = User
    CreditsApi.name_attr  = :name
  end

  it "deposits" do
    expect do
      CreditsApi::Transaction.deposit user1.id,   10
      CreditsApi::Transaction.deposit user1.id,  100
      CreditsApi::Transaction.deposit user1.id, 1000
    end.not_to raise_error

    expect(CreditsApi::Transaction.user_balance(user1.id)).to eq(1110)
  end

  it "withdraws" do
    expect do
      CreditsApi::Transaction.withdraw user1.id,   1
      CreditsApi::Transaction.withdraw user1.id,  50
      CreditsApi::Transaction.withdraw user1.id, 500
    end.not_to raise_error

    expect(CreditsApi::Transaction.user_balance(user1.id)).to eq(-551)
  end

  it "produces a user statement" do
    expect do
      CreditsApi::Transaction.deposit user1.id,   10
      CreditsApi::Transaction.deposit user1.id,  100
      CreditsApi::Transaction.deposit user2.id,  400
      CreditsApi::Transaction.deposit user3.id, 4000
      CreditsApi::Transaction.deposit user1.id, 1000
    end.not_to raise_error

    statement = CreditsApi::Transaction.statement(user1.id)
    arr = statement.map{|e| e[:amount]}.sort
    expect(arr).to eq([10,100,1000])

    arr = statement.map{|e| e[:balance]}.sort
    expect(arr).to eq([10,110,1110])
  end

  it "produces users balances" do
    expect do
      CreditsApi::Transaction.deposit user1.id,   10.0
      CreditsApi::Transaction.deposit user1.id,  100.0
      CreditsApi::Transaction.deposit user2.id,  400.0
      CreditsApi::Transaction.deposit user3.id, 4000.0
      CreditsApi::Transaction.deposit user1.id, 1000.0
    end.not_to raise_error

    users = CreditsApi::Transaction.users
    right_users = [
      { name: user1.name, balance: 1110.0 },
      { name: user2.name, balance:  400.0 },
      { name: user3.name, balance: 4000.0 },
      { name: user4.name, balance:    0.0 }
    ].sort{|a,b| a[:name]<=>b[:name]}

    expect(users).to eq(right_users)
  end
end
