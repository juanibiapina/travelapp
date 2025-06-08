class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [ :google ]

  belongs_to :user, optional: false

  def self.from_omniauth(auth)
    account = where(email: auth.info.email).first_or_create do |a|
      a.email = auth.info.email
      a.password = Devise.friendly_token[0, 20]
      a.provider = auth.provider
      a.uid = auth.uid
      
      # Create associated user with proper name handling
      name_value = auth.info[:name] || auth.info['name']
      user_name = name_value.present? ? name_value : auth.info.email.split('@').first
      a.user = User.create!(
        name: user_name,
        picture: auth.info.image
      )
    end

    # Update provider, uid for existing accounts
    account.update(
      provider: auth.provider,
      uid: auth.uid
    )
    
    # Update user info only if name is present and not nil/empty
    name_value = auth.info[:name] || auth.info['name']
    if name_value.present?
      account.user.update(
        name: name_value,
        picture: auth.info.image
      )
    elsif auth.info.image.present?
      # Update picture even if no name
      account.user.update(picture: auth.info.image)
    end
    
    account
  end
end
