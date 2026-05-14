class AddUserToDiscussionQuestion < ActiveRecord::Migration[8.0]
  def change
    add_reference :discussion_questions, :user, null: true, index: true, foreign_key: true
  end
end
