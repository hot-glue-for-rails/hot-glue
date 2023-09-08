class DfgPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def name_able?
    @record.sent_at.nil?
  end

  def update?
     if !@user.is_admin?
       return false
    elsif record.name_changed? && !name_able?
      record.errors.add(:name, "cannot be changed.")
      return false
    else
      return true
    end
  end

  class Scope < Scope
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
  end
end
