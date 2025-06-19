class Accommodation < ApplicationRecord
  include DateRangeValidatable

  belongs_to :place

  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  # Delegate trip access through place
  delegate :trip, to: :place
end
