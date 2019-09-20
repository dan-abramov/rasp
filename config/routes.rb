Rails.application.routes.draw do
  resources :pages do
    get :schedule, on: :collection
    get :stations, on: :collection
    get :arrivals, on: :collection
    get :results, on: :collection
    post :get_schedule, on: :collection
    get :autocomplete_bus_station_name, on: :collection
  end
end
