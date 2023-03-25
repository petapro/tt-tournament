Rails.application.routes.draw do
  root 'players#index'

  post "/players/remove_group_from_player/:id/:gruppennummer" => "players#remove_group_from_player"
  post "/players/add_player_to_group/:id/:gruppennummer" => "players#add_player_to_group"
  post "/players/show_results_in_group/:gruppennummer" => "players#show_results_in_group"
  post "/players/update_set_in_match/:matchid/:setnummer/:ballanzahl" => "players#update_set_in_match"
  post "/players/update_set_in_match/:matchid/:setnummer" => "players#update_set_in_match"
  post "/players/erzeuge_player/:player" => "players#erzeuge_player"

  resources :players


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

 end
