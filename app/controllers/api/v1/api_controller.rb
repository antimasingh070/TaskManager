module Api
    module V1
      class ApiController < ActionController::API
        require 'net/http'
        require 'uri'
        require 'json'
  
        serialization_scope :view_context
        include ActiveStorage::SetCurrent
        include Api::RendererHelper
        include ActionController::HttpAuthentication::Token::ControllerMethods
   
        before_action :authenticate_user!

        
        def authenticate_user!
            token = request.headers['Authorization']&.split&.last
          
            if token.nil?
              render_error({ error: 'Token not provided' }, "")
            else
              begin
                decoded_token = JwtToken.decode(token)
                user_id = decoded_token[:user_id]
                @current_user = User.find_by(id: user_id)
          
                render_error({ error: 'Unauthorized' }, "") unless @current_user
              rescue JWT::DecodeError
                render_error({ error: 'Invalid token' }, "")
              end
            end
          end          
      end
    end
end  