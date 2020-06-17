class ArticleAbility
  include CanCan::Ability

  def initialize(user)
    can :read, Article
    can :create, Article
    can :update, Article, user_id: user.id
    can :destroy, Article, user_id: user.id
    if user.admin?
      can :manage, Article
    end
  end
end