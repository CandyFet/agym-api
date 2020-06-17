class PostAbility
  include CanCan::Ability

  def initialize(user)
    can :read, Post
    can :create, Post
    can :update, Post, user_id: user.id
    can :destroy, Post, user_id: user.id
    if user.admin?
      can :manage, Post
    end
  end
end