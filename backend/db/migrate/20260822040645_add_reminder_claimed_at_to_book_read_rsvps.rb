class AddReminderClaimedAtToBookReadRsvps < ActiveRecord::Migration[8.0]
  def change
    add_column :book_read_rsvps, :reminder_claimed_at, :datetime
  end
end
