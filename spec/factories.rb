Factory.define :admin do |f|
  f.email "admin@domain.com"
  f.password "foobar"
  f.password_confirmation { |x| x.password }
  f.remember_me true
end

Factory.define :user do |f|
  f.email "user@domain.com"
  f.password "foobar"
  f.password_confirmation { |x| x.password }
  f.remember_me true
end

Factory.define :category do |f|
  f.enabled true
end

Factory.define :page do |f|
  f.enabled true
end

Factory.define :discussion do |f|
  f.title "New discussion"
  f.enabled true
end

Factory.define :say do |f|
  f.text "New question"
  f.enabled true
end
