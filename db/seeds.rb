Redirect.delete_all

current_redirects = {
}

current_redirects.each do |from, to|
  Redirect.create :from => from, :to => to
end
