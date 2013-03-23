class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    else
      can :read, Discussion, :enabled => true
      can :read, Say

      if user.persisted?
        can :create, Discussion, :enabled => true, :author_id => user.id, :author_type => 'User'
        can :manage, Say, :author_id => user.id, :author_type => 'User'
      end
    end
  end
end
