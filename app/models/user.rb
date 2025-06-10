class User < ApplicationRecord
  has_one :account, dependent: :destroy
  has_many :trip_memberships, dependent: :destroy
  has_many :member_trips, through: :trip_memberships, source: :trip
  has_many :created_invites, class_name: "Invite", foreign_key: "created_by_id", dependent: :destroy
  has_many :transport_users, dependent: :destroy
  has_many :transports, through: :transport_users

  validates :name, presence: true

  # Get all trips the user has access to (owned + member of)
  def all_trips
    Trip.joins(:trip_memberships)
        .where(trip_memberships: { user_id: id })
        .distinct
  end
end
