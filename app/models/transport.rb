class Transport < ApplicationRecord
  belongs_to :trip
  belongs_to :origin_place, class_name: "Place"
  belongs_to :destination_place, class_name: "Place"

  has_many :transport_users, dependent: :destroy
  has_many :users, through: :transport_users

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_or_equal_to_start_date
  validate :dates_within_trip_range
  validate :places_belong_to_same_trip

  private

  def end_date_after_or_equal_to_start_date
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, "must be after or equal to the start date")
    end
  end

  def dates_within_trip_range
    return unless trip&.start_date && trip&.end_date

    if start_date && start_date < trip.start_date
      errors.add(:start_date, "must be on or after the trip start date (#{trip.start_date.strftime('%B %d, %Y')})")
    end

    if start_date && start_date > trip.end_date
      errors.add(:start_date, "must be on or before the trip end date (#{trip.end_date.strftime('%B %d, %Y')})")
    end

    if end_date && end_date < trip.start_date
      errors.add(:end_date, "must be on or after the trip start date (#{trip.start_date.strftime('%B %d, %Y')})")
    end

    if end_date && end_date > trip.end_date
      errors.add(:end_date, "must be on or before the trip end date (#{trip.end_date.strftime('%B %d, %Y')})")
    end
  end

  def places_belong_to_same_trip
    if origin_place.present? && origin_place.trip_id != trip_id
      errors.add(:origin_place, "must belong to the same trip")
    end

    if destination_place.present? && destination_place.trip_id != trip_id
      errors.add(:destination_place, "must belong to the same trip")
    end
  end
end
