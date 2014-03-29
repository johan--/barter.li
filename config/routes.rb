BarterLi::Application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users
  namespace :api do
    namespace :v1, defaults:{format: 'json'} do
        get "/facebook", to: 'authentications#facebook'
        get '/share_token', to: 'users#get_share_token'
        get '/tags', to: 'books#get_tags'
        get '/profile_image', to: 'users#get_profile_image'
        post '/profile_image', to: 'users#set_profile_image'
        post '/auth_token', to: 'authentications#get_auth_token'
        post '/create_user', to: 'authentications#create_user'
        get '/user_preferred_location', to: 'users#get_user_preferred_location'
        post '/user_preferred_location', to: 'users#set_user_preferred_location'
        get '/search', to: "search#search"
        post '/barter_notification', to: "barters#send_barter_notification"
        get '/user_profile', to: "users#user_profile"
        get '/current_user_profile', to: "users#show"
        post '/register', to: 'public#register'
        post '/update_user', to: 'users#update'
        put '/user_update', to: "users#update"
        post '/feedback', to: "tracker#create_feedback"
        get '/ampq', to: "messages#ampq"
        get '/book_info', to: 'books#book_info'
        get '/book_suggestions', to: 'books#book_suggestions'
        get '/hangouts', to: 'locations#hangouts'
        post '/change_owner', to: 'books#change_owner'
        post '/wish_list', to: 'books#set_wish_list'
        get '/wish_list', to: 'books#get_wish_list'
        resources :books
    end
  end
   
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
