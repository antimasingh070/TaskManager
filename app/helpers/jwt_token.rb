require 'jwt'

module JwtToken
  SECRET_KEY = Rails.application.secrets.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now)
    binding.pry
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    binding.pry
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  end
end