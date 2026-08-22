require "test_helper"

class BookReadRsvpTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  def setup
    @book_read = book_reads(:one)
    @user = users(:one)
  end

  test "is valid with a book read and user" do
    rsvp = BookReadRsvp.new(book_read: @book_read, user: @user, status: :going)
    assert rsvp.valid?
  end

  test "requires a unique user per book read" do
    BookReadRsvp.create!(book_read: @book_read, user: @user, status: :going)
    duplicate = BookReadRsvp.new(book_read: @book_read, user: @user, status: :going)

    assert_not duplicate.valid?
  end

  test "allows going when capacity is available" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    rsvp = BookReadRsvp.new(book_read: @book_read, user: @user, status: :going)
    assert rsvp.valid?
  end

  test "prevents going when capacity is full" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    rsvp = BookReadRsvp.new(book_read: @book_read, user: users(:three), status: :going)
    assert_not rsvp.valid?
    assert_includes rsvp.errors.full_messages, "This session is full"
  end

  test "allows waitlisted when capacity is full" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    rsvp = BookReadRsvp.new(book_read: @book_read, user: users(:three), status: :waitlisted)
    assert rsvp.valid?
  end

  test "sends confirmation email after create if status is going" do
    assert_enqueued_emails 1 do
      BookReadRsvp.create!(book_read: @book_read, user: @user, status: :going)
    end
  end

  test "sends confirmation email after update if status changed to going" do
    rsvp = BookReadRsvp.create!(book_read: @book_read, user: @user, status: :cancelled)

    assert_enqueued_emails 1 do
      rsvp.update!(status: :going)
    end
  end

  test "does not send confirmation email if status changed to cancelled" do
    rsvp = BookReadRsvp.create!(book_read: @book_read, user: @user, status: :going)

    assert_enqueued_emails 0 do
      rsvp.update!(status: :cancelled)
    end
  end

  test "auto-promotes oldest waitlisted user when a going user cancels" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    going2 = BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)
    waitlisted = BookReadRsvp.create!(book_read: @book_read, user: users(:three), status: :waitlisted)

    assert_enqueued_emails 1 do
      BookReadRsvp.rsvp!(book_read: @book_read, user: going2.user, status: :cancelled)
    end

    assert_equal "going", waitlisted.reload.status
  end

  test "does not promote when no waitlisted users exist" do
    @book_read.update!(max_capacity: 2)
    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    going2 = BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    assert_enqueued_emails 0 do
      BookReadRsvp.rsvp!(book_read: @book_read, user: going2.user, status: :cancelled)
    end

    assert_equal "cancelled", going2.reload.status
  end

  test "does not promote when max_capacity is nil" do
    # @book_read max_capcity is nil
    going = BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    waitlisted = BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :waitlisted)

    assert_enqueued_emails 0 do
      BookReadRsvp.rsvp!(book_read: @book_read, user: going.user, status: :cancelled)
    end

    assert_equal "waitlisted", waitlisted.reload.status
  end

  test "promotes waitlisted users in FIFO order" do
    @book_read.update!(max_capacity: 2)
    going1 = BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)
    first_wait = BookReadRsvp.create!(book_read: @book_read, user: users(:three), status: :waitlisted)
    fourth_user = User.create!(email: "user4@example.com", password: "password123", username: "testuser4", name: "Test User Four", confirmed_at: Time.current)
    second_wait = BookReadRsvp.create!(book_read: @book_read, user: fourth_user, status: :waitlisted)

    BookReadRsvp.rsvp!(book_read: @book_read, user: going1.user, status: :cancelled)

    assert_equal "going", first_wait.reload.status
    assert_equal "waitlisted", second_wait.reload.status
  end
end
