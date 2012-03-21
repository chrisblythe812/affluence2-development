Affluence2::Application.routes.draw do



  ActiveAdmin.routes(self)


  get "home/index"
  #match '/profile/index' => 'profile#index', :as => :profile_index
  match '/home/latest_members' => 'home#latest_members', :as => :home_latest_members

#  get "home/index"

  devise_for :users, :controllers => {:registrations => "registrations", :sessions => "sessions"}


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
     resources :events do
       member do
       end
  #
       collection do
         get 'home_page_events'
         get 'landing_page_events'
       end
     end

  resources :home do

  end

  resources :profile   do
    collection do
      get 'settings'
      get 'confirm'
      get 'confirm_credit_card_info'
    end
  end
  match 'profile/confirm' => 'profile#confirm', :as => :confirm_profile
  match 'profile/confirm_credit_card_info' => 'profile#confirm_credit_card_info', :as => :confirm_credit_card_info_profile



  resources :members do
    collection do
      get 'latest_members'
      get 'find_members'
    end
  end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
