Factory.define :admin do |a|
  a.email "admin@domain.com"
  a.password "foobar"
  a.password_confirmation { |x| x.password }
  a.remember_me true
end

Factory.define :user do |a|
  a.email "user@domain.com"
  a.password "foobar"
  a.password_confirmation { |x| x.password }
  a.remember_me true
end

Factory.define :category do |c|
  c.enabled true
  c.show_order 0
end

Factory.define :page do |p|
  p.enabled true
  p.show_order 0
end