Given /^a discussion titled "([^"]*)" has says:$/ do |title, says_table|
  discussion = Factory :discussion, :title => title, :author => User.find_by_email(says_table.hashes[0][:author])
  says_table.hashes.each do |say|
    Factory :say, :text => say[:text], :author => User.find_by_email(say[:author]), :discussion => discussion
  end
end
