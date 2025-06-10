class Trip < ApplicationRecord
  has_many :links, dependent: :destroy
  has_many :trip_events, dependent: :destroy
  has_many :trip_memberships, dependent: :destroy
  has_many :members, through: :trip_memberships, source: :user
  has_many :invites, dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  # Get the owner of the trip
  def owner
    trip_memberships.find_by(role: "owner")&.user
  end

  # Check if a user is a member of the trip
  def member?(user)
    return false unless user
    trip_memberships.exists?(user: user)
  end

  # Check if a user is the owner of the trip
  def owner?(user)
    return false unless user
    trip_memberships.exists?(user: user, role: "owner")
  end

  # Add a member to the trip
  def add_member(user, role: "member")
    return false if member?(user)
    trip_memberships.create(user: user, role: role)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
