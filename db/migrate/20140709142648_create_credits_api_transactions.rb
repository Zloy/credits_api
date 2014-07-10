class CreateCreditsApiTransactions < ActiveRecord::Migration
  def change
    create_table :credits_api_transactions do |t|
      t.references :user, index: true
      t.float :amount
      t.float :balance

      t.timestamps
    end
  end
end
