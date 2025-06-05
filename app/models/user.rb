class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [ :google ]

  has_many :trips, dependent: :destroy

  def self.from_omniauth(auth)
    user = where(email: auth.info.email).first_or_create do |u|
      u.email = auth.info.email
      u.password = Devise.friendly_token[0, 20]
    end

    # Update provider and uid for existing users too
    user.update(provider: auth.provider, uid: auth.uid)
    user
  end
end
