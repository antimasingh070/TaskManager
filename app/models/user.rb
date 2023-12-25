class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
        #  devise :database_authenticatable, :registerable,
        #  :recoverable, :rememberable, :validatable, :omniauthable, 
        #  omniauth_providers: [:google_oauth2], :authentication_keys => [:login]
  validates :phone, presence: true, format: { with: /\A\+\d+\z/, message: "must start with a '+' and contain only digits" }
end
