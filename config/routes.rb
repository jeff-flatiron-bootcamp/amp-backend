Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      post '/login', to: 'auth#create'
      post '/admin_create_lease', to: 'users#admin_create_lease'
      post '/admin_create_property', to: 'users#admin_create_property'

      get '/profile', to: 'users#profile'
      get '/admin_get_all_users', to: 'users#admin_get_all_users'
      get '/admin_get_lease_types', to: 'users#admin_get_lease_types'
      get '/admin_get_all_leases', to: 'users#admin_get_all_leases'
      get '/admin_get_all_properties', to: 'users#admin_get_all_properties'
      get '/admin_get_all_payments', to: 'users#admin_get_all_payments'
      get '/admin_get_all_active_leases', to: 'users#admin_get_all_active_leases'
      get '/admin_get_all_terminated_leases', to: 'users#admin_get_all_terminated_leases'

      patch '/admin_terminate_lease', to: 'users#admin_terminate_lease'
      patch '/admin_apply_payment_to_lease', to: 'users#admin_apply_payment_to_lease'                      

    end
  end
end
