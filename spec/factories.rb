Factory.define :admin do |a|
  a.password "bar"
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