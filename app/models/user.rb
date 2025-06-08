class User < ApplicationRecord
  has_one :account, dependent: :destroy
  has_many :trip_memberships, dependent: :destroy
  has_many :member_trips, through: :trip_memberships, source: :trip
  has_many :created_invites, class_name: "Invite", foreign_key: "created_by_id", dependent: :destroy

  # Require name for all users
  validates :name, presence: true

  # Scopes for different user types
  scope :with_account, -> { joins(:account) }
  scope :without_account, -> { left_joins(:account).where(accounts: { id: nil }) }

  # Get all trips the user has access to (owned + member of)
  def all_trips
    Trip.joins(:trip_memberships)
        .where(trip_memberships: { user_id: id })
        .distinct
  end

  # Check if user has an account for authentication
  def has_account?
    account.present?
  end
end
