require "test_helper"

class SendBookReadRemindersJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  def setup
    @book_read = book_reads(:one)
    @book_read.update!(meetup_time: 12.hours.from_now)
    @user1 = users(:one)
    @user2 = users(:two)
    BookReadRsvp.find_or_create_by!(book_read: @book_read, user: @user1) { |r| r.status = :going }
    BookReadRsvp.find_or_create_by!(book_read: @book_read, user: @user2) { |r| r.status = :going }
  end

  test "sends reminder emails to going RSVPs within 24h window" do
    assert_emails 2 do
      SendBookReadRemindersJob.perform_now
    end

    @book_read.book_read_rsvps.going.each do |rsvp|
      assert_not_nil rsvp.reload.reminder_sent_at
    end
  end

  test "does not send duplicate reminders (idempotency)" do
    SendBookReadRemindersJob.perform_now

    assert_emails 0 do
      SendBookReadRemindersJob.perform_now
    end
  end

  test "does not send reminders for BookReads outside the 24h window" do
    @book_read.update!(meetup_time: 2.days.from_now)

    assert_emails 0 do
      SendBookReadRemindersJob.perform_now
    end
  end
end
