class Api::V1::OtpController < ApplicationController
    
    def request_otp
      user = User.find_by(phone_number: params[:phone_number])
  
      if user
        code = OtpService.generate_code
        Otp.create(user: user, code: code, expires_at: 5.minutes.from_now)
        OtpService.send_otp(user, code)
        render_success(message: 'OTP sent successfully')
      else
        render_error({ error: 'User not found' }, "")
      end
    end
  
    def verify_otp
      user = User.find_by(phone_number: params[:phone_number])
      otp = Otp.find_by(user: user, code: params[:code])
  
      if otp&.expires_at&.future?
        # Mark the OTP as used
        otp.update(used: true)
        render_success(message: 'OTP verified successfully')
      else
        render_error({ error: 'Invalid OTP' }, "")
      end
    end
end