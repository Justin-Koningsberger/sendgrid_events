Rails.application.routes.draw do
  get '/sg_events', to: "sg_events#index"
  post '/endpoint', to: 'sg_events#create'
end
