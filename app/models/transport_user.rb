class TransportUser < ApplicationRecord
  belongs_to :transport
  belongs_to :user

  validates :transport_id, uniqueness: { scope: :user_id }
end
