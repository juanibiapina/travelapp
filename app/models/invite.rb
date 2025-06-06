class Invite < ApplicationRecord
  belongs_to :trip
  belongs_to :created_by, class_name: "User"

  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  scope :active, -> { where(active: true) }
  scope :not_expired, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :valid_invites, -> { active.not_expired }

  def invite_valid?
    active? && !expired?
  end

  def expired?
    expires_at && expires_at < Time.current
  end

  def revoke!
    update!(active: false)
  end

  private

  def generate_token
    self.token = SecureRandom.hex(16) if token.blank?
  end
end
