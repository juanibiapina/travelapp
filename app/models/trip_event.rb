class TripEvent < ApplicationRecord
  belongs_to :trip

  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_or_equal_to_start_date

  private

  def end_date_after_or_equal_to_start_date
    return unless start_date && end_date

    if end_date < start_date
      errors.add(:end_date, "must be after or equal to the start date")
    end
  end
end
