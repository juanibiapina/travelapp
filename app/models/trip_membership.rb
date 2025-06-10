class TripMembership < ApplicationRecord
  belongs_to :trip
  belongs_to :user
  belongs_to :starting_place, class_name: "Place", optional: true

  enum :role, { owner: "owner", member: "member" }

  validates :role, presence: true
  validates :trip_id, uniqueness: { scope: :user_id }
  validate :starting_place_belongs_to_same_trip

  private

  def starting_place_belongs_to_same_trip
    return unless starting_place.present?

    unless starting_place.trip_id == trip_id
      errors.add(:starting_place, "must belong to the same trip")
    end
  end
end
