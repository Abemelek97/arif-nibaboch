class ChangeStatusNullOnDiscussionQuestions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :discussion_questions, :status, false, 0
    change_column_null :discussion_questions, :position, false, 0
  end
end
