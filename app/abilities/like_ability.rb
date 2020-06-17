class LikeAbility
  include CanCan::Ability

  def initialize(user)
    can :read, Like
    can :create, Like
    can :destroy, Like, user_id: user.id
    if user.admin?
      can :manage, Like
    end
  end
end