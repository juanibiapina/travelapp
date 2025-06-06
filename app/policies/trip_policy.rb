# frozen_string_literal: true

class TripPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && record.member?(user)
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
        # Return trips the user is a member of
        scope.joins(:trip_memberships)
             .where(trip_memberships: { user_id: user.id })
             .distinct
      else
        scope.none
      end
    end
  end
end
