# frozen_string_literal: true

class AccommodationPolicy < ApplicationPolicy
  def index?
    user.present? && trip_accessible_by_user?
  end

  def show?
    user.present? && trip_accessible_by_user?
  end

  def create?
    user.present? && (record.place&.trip&.owner?(user) || true) # Allow creation, validation happens in controller
  end

  def update?
    user.present? && trip_owned_by_user?
  end

  def destroy?
    user.present? && trip_owned_by_user?
  end

  private

  def trip_accessible_by_user?
    record.place&.trip&.member?(user) || false
  end

  def trip_owned_by_user?
    record.place&.trip&.owner?(user) || false
  end

  class Scope < Scope
    def resolve
      if user.present?
        scope.joins(place: { trip: :trip_memberships })
             .where(trip_memberships: { user_id: user.id })
             .distinct
      else
        scope.none
      end
    end
  end
end
