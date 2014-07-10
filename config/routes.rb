CreditsApi::Engine.routes.draw do
  get  "users"                       => "users#index"
  get  "users/:id/statement"         => "users#statement"
  post "users/:id/deposit/:amount"   => "users#deposit" 
  post "users/:id/withdraw/:amount"  => "users#withdraw"
end
