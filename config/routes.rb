Rails.application.routes.draw do
  get '/sg_events', to: 'sg_events#index'
  get '/sg_events/:id', to: 'sg_events#show'
  get '/search', to: 'sg_events#index'
  post '/endpoint', to: 'sg_events#create'
end
