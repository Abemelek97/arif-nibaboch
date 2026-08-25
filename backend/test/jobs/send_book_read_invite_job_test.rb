require "test_helper"

class SendBookReadInviteJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  def setup
    @book_read = book_reads(:one)
    @user1 = users(:one)
    @user2 = users(:two)
    BookReadRsvp.find_or_create_by!(book_read: @book_read, user: @user1) { |r| r.status = :going }
    BookReadRsvp.find_or_create_by!(book_read: @book_read, user: @user2) { |r| r.status = :going }
  end

  test "delivers update emails when calendar_sequence matches" do
    @book_read.update!(meetup_location: "New Hall B") # calendar_sequence becomes 1

    assert_enqueued_emails 2 do
      SendBookReadInviteJob.perform_now(@book_read.id, 1)
    end
  end

  test "exits silently when expected_sequence does not match current calendar_sequence" do
    @book_read.update!(meetup_location: "New Hall B") # sequence = 1
    @book_read.update!(meetup_location: "New Hall C") # sequence = 2

    # Job 1 was enqueued for sequence 1, but current sequence is 2
    assert_no_enqueued_emails do
      SendBookReadInviteJob.perform_now(@book_read.id, 1)
    end
  end
end
