# frozen_string_literal: true

class TripPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && (record.user == user || record.member?(user))
  end

  def create?
    user.present?
  end

  def update?
    user.present? && record.owner?(user)
  end

  def destroy?
    user.present? && record.owner?(user)
  end

  class Scope < Scope
    def resolve
      if user.present?
        # Return trips the user owns or is a member of
        scope.joins("LEFT JOIN trip_memberships ON trips.id = trip_memberships.trip_id")
             .where("trips.user_id = ? OR trip_memberships.user_id = ?", user.id, user.id)
             .distinct
      else
        scope.none
      end
    end
  end
end
