Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Scope all routes under /api
  scope '/api' do
    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    get 'flights/fetch_flights', to: 'flights#fetch_flights'
    get 'flights', to: 'flights#index'
    get 'flights/search', to: 'flights#search'

    # Routes for metadata
    get 'airports', to: 'metadata#airports'
    get 'airlines', to: 'metadata#airlines'
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
