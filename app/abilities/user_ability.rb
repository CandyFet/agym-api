class UserAbility
  include CanCan::Ability

  def initialize(user)
    can :read, User
    can :update, User, id: user.id
    can :destroy, User, id: user.id
    if user.admin?
      can :manage, User
    end
  end
end