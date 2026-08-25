class SendBookReadInviteJob < ApplicationJob
  queue_as :default

  def perform(book_read_id, expected_sequence)
    book_read = BookRead.find_by(id: book_read_id)
    return if book_read.nil?
    return if book_read.calendar_sequence != expected_sequence

    book_read.book_read_rsvps.going.includes(:user).each do |rsvp|
      UserMailer.with(rsvp: rsvp, time_zone: Time.zone.name).book_read_updated_invite.deliver_later
    end
  end
end
