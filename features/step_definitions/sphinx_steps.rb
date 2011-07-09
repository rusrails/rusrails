Given 'the Sphinx indexes are updated' do
  # Update all indexes
  ThinkingSphinx::Test.index
  sleep(0.25) # Wait for Sphinx to catch up
end

Given 'the Sphinx indexes for articles are updated' do
  # Update specific indexes
  ThinkingSphinx::Test.index 'article_core', 'article_delta'
  sleep(0.25) # Wait for Sphinx to catch up
end