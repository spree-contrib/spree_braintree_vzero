Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :orders do
      post :clone, on: :member
    end
  end
end
