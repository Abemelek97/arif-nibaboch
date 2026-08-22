# Preview all emails at http://localhost:3000/rails/mailers
class UserMailerPreview < ActionMailer::Preview
  def rsvp_confirmation
    rsvp = BookReadRsvp.going.last || BookReadRsvp.last
    UserMailer.with(rsvp: rsvp).rsvp_confirmation
  end

  def book_read_reminder_email
    rsvp = BookReadRsvp.going.last || BookReadRsvp.last
    UserMailer.with(rsvp: rsvp).book_read_reminder_email
  end
end
