Admin.create :email => "admin@domain.com", :password => "123456" unless Admin.exists?

Redirect.delete_all

current_redirects = {
  '/rails-routing/breaking-up-a-large-route-file' => '/rails-routing'
}

current_redirects.each do |from, to|
  Redirect.create :from => from, :to => to
end
