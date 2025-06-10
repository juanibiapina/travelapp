class TripEvent < ApplicationRecord
  belongs_to :trip

  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_or_equal_to_start_date
  validate :dates_within_trip_range

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
end
