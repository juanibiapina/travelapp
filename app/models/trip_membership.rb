class TripMembership < ApplicationRecord
  belongs_to :trip
  belongs_to :user

  enum :role, { owner: "owner", member: "member" }

  validates :role, presence: true
  validates :trip_id, uniqueness: { scope: :user_id }
end
