Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create, :show, :destroy, :update, :index] do
        collection do 
          get :login
          post :reset_password
          post :sign_up
        end
      end

      resources :otps, only:[] do
        collection do
          post :request_otp
          post :verify_otp
        end
      end
    end
  end  
end
