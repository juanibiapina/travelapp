class Trip < ApplicationRecord
  belongs_to :user # Keep for backward compatibility - this is the original owner
  has_many :links, dependent: :destroy
  has_many :trip_memberships, dependent: :destroy
  has_many :members, through: :trip_memberships, source: :user
  has_many :invites, dependent: :destroy

  # Get the owner of the trip
  def owner
    trip_memberships.find_by(role: "owner")&.user || user
  end

  # Check if a user is a member of the trip
  def member?(user)
    return false unless user
    trip_memberships.exists?(user: user) || self.user == user
  end

  # Check if a user is the owner of the trip
  def owner?(user)
    return false unless user
    trip_memberships.exists?(user: user, role: "owner") || self.user == user
  end

  # Add a member to the trip
  def add_member(user, role: "member")
    return false if member?(user)
    trip_memberships.create(user: user, role: role)
  end
end
