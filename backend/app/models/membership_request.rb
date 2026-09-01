class MembershipRequest < ApplicationRecord
  belongs_to :user
  belongs_to :book_club

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :user_id, uniqueness: { scope: :book_club_id, message: "already has a request for this club" }

  def approve!
    transaction do
      update!(status: :approved)
      book_club.book_club_members.find_or_create_by!(user: user)
    end
  end

  def reject!
    update!(status: :rejected)
  end
end
