Rails.application.routes.draw do
  root to: 'pages#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/search' => 'pages#search'
  get '/access_token' => 'pages#access_token'
  get '/mydata' => 'pages#my_data'
  get '/subreddit' => 'pages#lsit_subreddit'
end
