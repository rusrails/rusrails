class NullifyPreviousDiscussionSubject < ActiveRecord::Migration
  def up
    Discussion.update_all(subject_id: nil, subject_type: nil)
  end

  def down
  end
end
