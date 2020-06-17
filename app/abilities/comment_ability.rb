class CommentAbility
  include CanCan::Ability

  def initialize(user)
    can :read, Comment
    can :create, Comment
    can :update, Comment, user_id: user.id
    can :destroy, Comment, user_id: user.id
    if user.admin?
      can :manage, Comment
    end
  end
end