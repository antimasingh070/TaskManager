class OtpService
    def self.generate_code
      SecureRandom.random_number(10**6).to_s.rjust(6, '0')
    end
  
    def self.send_otp(user, code)
      # Use your SMS provider's API to send the OTP to the user's phone number
      message = "Your OTP is: #{code}"
      MessageBird::Message.create(to: user.phone_number, body: message)
    end
end