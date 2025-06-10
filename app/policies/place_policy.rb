# frozen_string_literal: true

class PlacePolicy < ApplicationPolicy
  def index?
    user.present? && trip_accessible_by_user?
  end

  def show?
    user.present? && trip_accessible_by_user?
  end

  def create?
    user.present? && trip_owned_by_user?
  end

  def update?
    user.present? && trip_owned_by_user?
  end

  def destroy?
    user.present? && trip_owned_by_user?
  end

  private

  def trip_accessible_by_user?
    record.trip.member?(user)
  end

  def trip_owned_by_user?
    record.trip.owner?(user)
  end

  class Scope < Scope
    def resolve
      if user.present?
        scope.joins(trip: :trip_memberships)
             .where(trip_memberships: { user_id: user.id })
             .distinct
      else
        scope.none
      end
    end
  end
end
