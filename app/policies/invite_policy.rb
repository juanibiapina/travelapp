# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  def create?
    user.present? && trip_owned_by_user?
  end

  def destroy?
    user.present? && trip_owned_by_user?
  end

  private

  def trip_owned_by_user?
    record.trip.owner?(user)
  end

  class Scope < Scope
    def resolve
      if user.present?
        scope.joins(:trip).where(trips: { user: user })
      else
        scope.none
      end
    end
  end
end
