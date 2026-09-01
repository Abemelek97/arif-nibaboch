class MembershipRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book_club
  before_action :set_membership_request, only: [ :approve, :reject, :cancel ]
  before_action :require_club_owner, only: [ :approve, :reject ]
  before_action :require_request_owner, only: [ :cancel ]

  def create
    if @book_club.has_member?(current_user)
      redirect_to @book_club, notice: "You are already a member."
      return
    end

    @membership_request = @book_club.membership_requests.find_or_initialize_by(user: current_user)

    if @membership_request.persisted? && @membership_request.pending?
      redirect_to @book_club, notice: "Your join request is pending approval."
      return
    end

    if @membership_request.persisted?
      # Re-applying after rejection or after leaving a previously approved membership:
      # reset the stale record to pending so the owner reviews it again
      @membership_request.update!(status: :pending)
    else
      @membership_request.save!
    end

    if @book_club.owner.present?
      UserMailer.with(membership_request: @membership_request).membership_request_notification.deliver_later
    end

    respond_to do |format|
      format.html { redirect_to @book_club, notice: "Your join request has been submitted." }
      format.turbo_stream { flash.now[:notice] = "Your join request has been submitted." }
    end
  end

  def approve
    @membership_request.approve!
    @membership = @book_club.book_club_members.find_by(user: @membership_request.user)
    UserMailer.with(membership_request: @membership_request).membership_request_decision.deliver_later
    respond_to do |format|
      format.html { redirect_to @book_club, notice: "Request approved." }
      format.turbo_stream { flash.now[:notice] = "Request approved." }
    end
  end

  def reject
    @membership_request.reject!
    UserMailer.with(membership_request: @membership_request).membership_request_decision.deliver_later
    respond_to do |format|
      format.html { redirect_to @book_club, notice: "Request rejected." }
      format.turbo_stream { flash.now[:notice] = "Request rejected." }
    end
  end

  def cancel
    @membership_request.destroy!
    respond_to do |format|
      format.html { redirect_to @book_club, notice: "Join request cancelled." }
      format.turbo_stream { flash.now[:notice] = "Join request cancelled." }
    end
  end

  private

  def set_book_club
    @book_club = BookClub.find(params[:book_club_id])
  end

  def set_membership_request
    @membership_request = @book_club.membership_requests.find(params[:id])
  end

  def require_club_owner
    unless @book_club.owner == current_user
      redirect_to @book_club, alert: "You do not have permission to do that."
    end
  end

  def require_request_owner
    unless @membership_request.user_id == current_user.id
      redirect_to @book_club, alert: "You do not have permission to do that."
    end
  end
end
