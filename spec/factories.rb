FactoryGirl.define  do
  factory :user do
    email "user@domain.com"
    password "foobar"
    password_confirmation { |x| x.password }
    remember_me true
  end

  factory :category do
    enabled true
  end

  factory :page do
    enabled true
  end

  factory :discussion do
    title "New discussion"
    enabled true
  end

  factory :say do
    text "New question"
    enabled true
  end
end
