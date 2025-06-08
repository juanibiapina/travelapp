class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable,
         omniauth_providers: [ :google ]

  has_many :trip_memberships, dependent: :destroy
  has_many :member_trips, through: :trip_memberships, source: :trip
  has_many :created_invites, class_name: "Invite", foreign_key: "created_by_id", dependent: :destroy

  # Override Devise's email validation to make it conditional
  validates :email, presence: true, uniqueness: true, if: :has_account?
  validates :email, format: { with: Devise.email_regexp }, if: -> { has_account? && email.present? }

  # Override Devise's password validation to make it conditional
  validates :encrypted_password, presence: true, if: :has_account?

  # Require name for users without accounts (since they don't have email)
  validates :name, presence: true, if: -> { !has_account? }

  # Scopes for different user types
  scope :with_account, -> { where(has_account: true) }
  scope :without_account, -> { where(has_account: false) }

  def self.from_omniauth(auth)
    user = where(email: auth.info.email).first_or_create do |u|
      u.email = auth.info.email
      u.password = Devise.friendly_token[0, 20]
      u.name = auth.info.name
      u.picture = auth.info.image
      u.has_account = true
    end

    # Update provider, uid, name, and picture for existing users too
    user.update(
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name,
      picture: auth.info.image,
      has_account: true
    )
    user
  end

  # Get all trips the user has access to (owned + member of)
  def all_trips
    Trip.joins(:trip_memberships)
        .where(trip_memberships: { user_id: id })
        .distinct
  end

  # Override Devise's email_required? method
  def email_required?
    has_account?
  end

  # Override Devise's password_required? method
  def password_required?
    has_account? && (persisted? ? !password.nil? : true)
  end
end
