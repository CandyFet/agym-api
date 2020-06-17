class RepostAbility
  include CanCan::Ability

  def initialize(user)
    can :read, Repost
    can :create, Repost
    can :destroy, Repost, user_id: user.id
    if user.admin?
      can :manage, Repost
    end
  end
end