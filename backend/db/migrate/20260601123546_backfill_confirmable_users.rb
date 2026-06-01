class BackfillConfirmableUsers < ActiveRecord::Migration[8.0]
  def up
    execute("UPDATE users SET confirmed_at = CURRENT_TIMESTAMP WHERE confirmed_at IS NULL")
  end

  def down
    # No need to revert this migration
  end
end
