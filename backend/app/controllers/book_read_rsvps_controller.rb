class BookReadRsvpsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_club
  before_action :set_book_read

  def create
    ensure_membership!
    @rsvp = BookReadRsvp.rsvp!(book_read: @book_read, user: current_user, status: :going)
    @rsvp_users = @book_read.book_read_rsvps.going.includes(:user).map(&:user)

    respond_to do |format|
      format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: rsvp_notice(@rsvp) }
      format.turbo_stream { flash.now[:notice] = rsvp_notice(@rsvp) }
    end
  end

  def update
    ensure_membership!
    status = params.dig(:book_read_rsvp, :status) || :going
    @rsvp = BookReadRsvp.rsvp!(book_read: @book_read, user: current_user, status: status)
    @rsvp_users = @book_read.book_read_rsvps.going.includes(:user).map(&:user)

    respond_to do |format|
      format.html { redirect_to book_club_book_read_path(@book_club, @book_read), notice: rsvp_notice(@rsvp) }
      format.turbo_stream { flash.now[:notice] = rsvp_notice(@rsvp) }
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end

  def set_book_read
    @book_read = @book_club.book_reads.find(params[:book_read_id])
  end

  def ensure_membership!
    @book_club.book_club_members.find_or_create_by!(user: current_user)
  end

  def rsvp_notice(rsvp)
    return "You are waitlisted for this read." if rsvp.waitlisted?
    return "Your RSVP was updated." if rsvp.cancelled?

    "You are going to this read."
  end
end
