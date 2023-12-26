module Api
    module V1
      class UsersController < ApiController
        # skip_before_action :verify_authenticity_token, only: :create
        skip_before_action :authenticate_user!, only: :create
        before_action :authenticate_with_otp, only: [:login]

        def reset_password
          method = nil
          user = if params[:token].present?
                   method = 'Token'
                   User.find_by(id: JwtToken.decode(params[:token])&.dig(:user_id))
                 elsif (params[:phone_number].present? || params[:email].present?) && params[:code].present?
                   method = 'OTP'
                   user = find_user_by_phone_or_email(params[:phone_number], params[:email])
                   otp = Otp.find_by(user: user, code: params[:code])
                   otp&.update(used: true) if otp&.expires_at&.future?
                   user
                 else
                   nil
                 end
      
          if user
            password = params[:password]
            if password.blank? || user.authenticate(password)
              # Render an error if the new password is blank or matches the old password
              render_error({ error: 'Invalid new password' }, "") and return if password.blank? || user.authenticate(password)
      
              # Reset the password
              user.update(password: password)
              token = JwtToken.encode(user_id: user.id)
              render_success(user: ::UserSerializer.new(user), token: token, message: "#{method} verified successfully and password reset")
            else
              render_error({ error: 'Invalid password' }, "")
            end
          else
            render_error({ error: "Invalid #{method}" }, "")
          end
        end

        def sign_up
            existing_user = User.find_by(email: params[:user][:email])
            if existing_user
              render_error({ error: 'User with this email already exists' }, "")
            else
              user = User.new(user_params)
              if user.save
                token = JwtToken.encode(user_id: user.id)
                render_success(user: ::UserSerializer.new(user), token: token)
              else
                render_error({ errors: user.errors.full_messages }, "")
              end
            end
        end

        def verify_and_login
            user = if params[:token].present?
                     method = 'Token'
                     User.find_by(id: JwtToken.decode(params[:token])&.dig(:user_id))
                   elsif (params[:phone_number].present? || params[:email].present?) && params[:code].present?
                     method = 'OTP'
                     user = find_user_by_phone_or_email(params[:phone_number], params[:email])
                     otp = Otp.find_by(user: user, code: params[:code])
                     otp&.update(used: true) if otp&.expires_at&.future?
                     user
                   else
                     nil
                   end
          
            if user
              password = params[:password]
              if password.blank? || user.authenticate(password)
                token = JwtToken.encode(user_id: user.id)
                render_success(user: ::UserSerializer.new(user), token: token, message: "#{method} verified successfully")
              else
                render_error({ error: 'Invalid email or password' }, "")
              end
            else
              render_error({ error: "Invalid #{method}" }, "")
            end
        end
          
        def index
            @user = User.all
            render_collection(@user, ::UserSerializer)
        end

        def show
            begin
              @user = User.find(params[:id])
              render_success(@user)
            rescue ActiveRecord::RecordNotFound
              render_resource_not_found
            end
        end

        def destroy
            @user = User.find(params[:id])
            @user.destroy
            render_error({ errors: "User deleted" }, "")
        end

        def update
            begin
              @user = User.find(params[:id])
              @user.update(user_params)
              render_success(@user)
            rescue ActiveRecord::RecordNotFound
              render_error({ errors: "User not found" }, "")
            end
        end

        private
        
        def find_user_by_phone_or_email(phone_number, email)
            return User.find_by(phone_number: phone_number) if phone_number.present?
            return User.find_by(email: email) if email.present?
        end

        def authenticate_with_otp
          user = current_user # Assuming you have a method to get the currently authenticated user
          otp = Otp.find_by(user: user, used: false)
      
          if otp&.expires_at&.future?
            # Mark the OTP as used
            otp.update(used: true)
          else
            render_error({ error: 'Invalid or expired OTP' }, "")
          end
        end

        def user_params
            params.require(:user).permit(
              :id, 
              :first_name, 
              :last_name, 
              :email, 
              :password, 
              :password_confirmation
            )
        end
      end
    end
end
  