class Place < ApplicationRecord
  include DateRangeValidatable

  belongs_to :trip

  has_many :accommodations, dependent: :destroy
  has_many :origin_transports, class_name: "Transport", foreign_key: "origin_place_id", dependent: :restrict_with_error
  has_many :destination_transports, class_name: "Transport", foreign_key: "destination_place_id", dependent: :restrict_with_error

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
end
