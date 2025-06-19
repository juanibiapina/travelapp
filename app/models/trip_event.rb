class TripEvent < ApplicationRecord
  include DateRangeValidatable

  belongs_to :trip

  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
end
