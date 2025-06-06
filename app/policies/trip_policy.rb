# frozen_string_literal: true

class TripPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && record.user == user
  end

  def create?
    user.present?
  end

  def update?
    user.present? && record.user == user
  end

  def destroy?
    user.present? && record.user == user
  end

  class Scope < Scope
    def resolve
      if user.present?
        scope.where(user: user)
      else
        scope.none
      end
    end
  end
end
