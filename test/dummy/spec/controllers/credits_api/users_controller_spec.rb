require "rails_helper"
require "byebug"
require "concurrency_helper"

RSpec.describe CreditsApi::UsersController, :type => :controller do
  routes { CreditsApi::Engine.routes }

  let!(:user1) { create(:user1) }
  let!(:user2) { create(:user2) }
  let!(:user3) { create(:user3) }
  let!(:user4) { create(:user4) }

  before :all do
    CreditsApi.user_class = User
    CreditsApi.name_attr  = :name
  end

  it "deposits" do
    post :deposit, {id: user1.id, amount: 10.0}
    response.status.should eql 200

    post :deposit, {id: user1.id, amount: 100.0}
    response.status.should eql 200

    post :deposit, {id: user1.id, amount: 1000.0}
    response.status.should eql 200

    # invalid amount values
    post :deposit, {id: user1.id, amount: "b"}    # bad float amount value
    response.status.should eql 403

    post :deposit, {id: user1.id, amount: 0.0}    # zero amount value
    response.status.should eql 403

    post :deposit, {id: user1.id, amount: -500.0} # negative amount value
    response.status.should eql 403

    # invalid id values
    post :deposit, {id: "x", amount: 10}    # bad id value
    response.status.should eql 403

    post :deposit, {id:   0, amount: 10}    # zero id value
    response.status.should eql 403

    post :deposit, {id:  -1, amount: 10} # negative id value
    response.status.should eql 403
    expect(CreditsApi::Transaction.user_balance(user1.id)).to eq(1110.0)
  end

  it "withdraws" do
    post :withdraw, {id: user1.id, amount: 1.0}
    response.status.should eql 200

    post :withdraw, {id: user1.id, amount: 50.0}
    response.status.should eql 200

    post :withdraw, {id: user1.id, amount: 500.0}
    response.status.should eql 200

    # invalid amount values
    post :withdraw, {id: user1.id, amount: "b"}    # bad float amount value
    response.status.should eql 403

    post :withdraw, {id: user1.id, amount: 0.0}    # zero amount value
    response.status.should eql 403

    post :withdraw, {id: user1.id, amount: -500.0} # negative amount value
    response.status.should eql 403

    # invalid id values
    post :withdraw, {id: "x", amount: 10}    # bad id value
    response.status.should eql 403

    post :withdraw, {id:   0, amount: 10}    # zero id value
    response.status.should eql 403

    post :withdraw, {id:  -1, amount: 10} # negative id value
    response.status.should eql 403

    expect(CreditsApi::Transaction.user_balance(user1.id)).to eq(-551.0)
  end

  it "produces a user statement" do
    expect do
      CreditsApi::Transaction.deposit user1.id,   10
      CreditsApi::Transaction.deposit user1.id,  100
      CreditsApi::Transaction.deposit user2.id,  400
      CreditsApi::Transaction.deposit user3.id, 4000
      CreditsApi::Transaction.deposit user1.id, 1000
    end.not_to raise_error

    get :statement, {id: user1.id}
    response.status.should eql 200
    statement = JSON.parse response.body

    arr = statement.map{|e| e["amount"]}.sort
    expect(arr).to eq([10.0, 100.0, 1000.0])

    arr = statement.map{|e| e["balance"]}.sort
    expect(arr).to eq([10.0, 110.0, 1110.0])

    # invalid id values
    get :statement, {id: "x"}    # bad id value
    response.status.should eql 403

    get :statement, {id:   0}    # zero id value
    response.status.should eql 403

    get :statement, {id:  -1} # negative id value
    response.status.should eql 403
  end

  it "produces users balances" do
    expect do
      CreditsApi::Transaction.deposit user1.id,   10.0
      CreditsApi::Transaction.deposit user1.id,  100.0
      CreditsApi::Transaction.deposit user2.id,  400.0
      CreditsApi::Transaction.deposit user3.id, 4000.0
      CreditsApi::Transaction.deposit user1.id, 1000.0
    end.not_to raise_error

    get :index
    response.status.should eql 200
    users = JSON.parse response.body

    right_users = [
      { "name" => user1.name, "balance" => 1110.0 },
      { "name" => user2.name, "balance" =>  400.0 },
      { "name" => user3.name, "balance" => 4000.0 },
      { "name" => user4.name, "balance" =>    0.0 }
    ].sort{|a,b| a["name"]<=>b["name"]}

    expect(users).to eq(right_users)
  end

  xit "withdraws and deposits with concurrency" do
    forks, repetitions = 50, 10
    deposit_amount, withdraw_amount = 10.0, 1.0

    config = ActiveRecord::Base.remove_connection       
    (1..forks).each do
      fork_with_new_connection(config) do
        (1..repetitions).each do
          puts user1.inspect
          post :withdraw, {id: user1.id, amount: withdraw_amount}
          response.status.should eql 200

          post :deposit,  {id: user1.id, amount: deposit_amount}
          response.status.should eql 200
        end
      end
    end
    ActiveRecord::Base.establish_connection(config)

    balance = CreditsApi::Transaction.user_balance(user1.id)
    right_balance = forks * repetitions * (deposit_amount - withdraw_amount)
    expect(balance).to eq(right_balance)
  end
end
