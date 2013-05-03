ThinkingSphinx::Index.define 'static_docs/page', with: :active_record do
  indexes title
  indexes body
end
