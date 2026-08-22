require "test_helper"

class BookReadRsvpsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @book_club = book_clubs(:one)
    @book_read = book_reads(:one)
  end

  test "creates rsvp and auto-joins membership" do
    user = users(:three)
    sign_in user

    assert_difference([ "BookReadRsvp.count", "BookClubMember.count" ]) do
      post book_club_book_read_rsvp_url(@book_club, @book_read)
    end

    created_rsvp = BookReadRsvp.find_by!(book_read: @book_read, user: user)
    assert_equal user, created_rsvp.user
  end

  test "cancels rsvp via update" do
    user = users(:three)
    sign_in user
    BookReadRsvp.create!(book_read: @book_read, user: user, status: :going)

    patch book_club_book_read_rsvp_url(@book_club, @book_read), params: {
      book_read_rsvp: { status: "cancelled" }
    }

    rsvp = BookReadRsvp.find_by(book_read: @book_read, user: user)
    assert_equal "cancelled", rsvp.status
  end

  test "auto-promotes waitlisted user when going user cancels" do
    @book_read.update!(max_capacity: 2)
    going_user = users(:one)
    waitlisted_user = users(:three)
    sign_in going_user

    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: going_user, status: :going)
    waitlisted = BookReadRsvp.create!(book_read: @book_read, user: waitlisted_user, status: :waitlisted)

    assert_enqueued_emails 1 do
      patch book_club_book_read_rsvp_url(@book_club, @book_read), params: {
        book_read_rsvp: { status: "cancelled" }
      }
    end

    assert_equal "going", waitlisted.reload.status
  end

  test "sets waitlisted_count for turbo stream after rsvp" do
    @book_read.update!(max_capacity: 2)
    user = users(:three)
    sign_in user

    BookReadRsvp.create!(book_read: @book_read, user: users(:one), status: :going)
    BookReadRsvp.create!(book_read: @book_read, user: users(:two), status: :going)

    assert_enqueued_emails 0 do
      post book_club_book_read_rsvp_url(@book_club, @book_read),
           as: :turbo_stream
    end

    rsvp = BookReadRsvp.find_by!(book_read: @book_read, user: user)
    assert_equal "waitlisted", rsvp.status
    assert_match "waitlisted", response.body.downcase
  end
end
