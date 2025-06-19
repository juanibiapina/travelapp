class Transport < ApplicationRecord
  include DateRangeValidatable

  belongs_to :trip
  belongs_to :origin_place, class_name: "Place"
  belongs_to :destination_place, class_name: "Place"

  has_many :transport_users, dependent: :destroy
  has_many :users, through: :transport_users

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :places_belong_to_same_trip

  private

  def places_belong_to_same_trip
    if origin_place.present? && origin_place.trip_id != trip_id
      errors.add(:origin_place, "must belong to the same trip")
    end

    if destination_place.present? && destination_place.trip_id != trip_id
      errors.add(:destination_place, "must belong to the same trip")
    end
  end
end
