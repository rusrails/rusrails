module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /^the home\s?page$/
      '/'
    
    when /the sign up page/
      '/admins/sign_up'

    when /the sign in page/
      '/admins/sign_in'

    when /^the category "([^"]*)"$/i
      Category.find_by_name($1).path
      
    when /^the page "([^"]*)"$/i
      Page.find_by_name($1).path
      
    when /^(\d+)-th page$/i
      @pages[$1.to_i-1].path

    when /the edit admin category "([^"]*)" page/
      edit_admin_category_path Category.find_by_name($1)
    
    when /the edit admin page "([^"]*)" page/
      edit_admin_page_path Page.find_by_name($1)
    
    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
