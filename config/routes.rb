Rails.application.routes.draw do
  resources :sg_events
  get '/search', to: 'sg_events#index'
  post '/endpoint', to: 'sg_events#create'
end
