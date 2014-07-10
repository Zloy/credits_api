user1 = User.create name: "Samuel L. Jackson"
user2 = User.create name: "Bruce Willis"
user3 = User.create name: "Arnold Schwarzenegger"
user4 = User.create name: "Robert De Niro"

CreditsApi::Transaction.deposit  user1.id, 100.0
CreditsApi::Transaction.deposit  user1.id, 10.0
CreditsApi::Transaction.deposit  user1.id, 1.0
CreditsApi::Transaction.deposit  user2.id, 1000
CreditsApi::Transaction.deposit  user4.id, 2000
CreditsApi::Transaction.withdraw user4.id, 2
