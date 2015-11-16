Spree::Core::Engine.routes.draw do

  namespace :admin do
    resources :orders do
      get :clone, on: :member
    end
  end

end
