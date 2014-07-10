Rails.application.routes.draw do

  mount CreditsApi::Engine, at: "api"
end
