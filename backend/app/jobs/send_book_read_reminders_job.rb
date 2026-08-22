class SendBookReadRemindersJob < ApplicationJob
  queue_as :default
  REMINDER_WINDOW = 24.hours

  def perform
    upcoming_reads = BookRead.where(meetup_time: Time.current..(Time.current + REMINDER_WINDOW))
    upcoming_reads.find_each do |book_read|
      book_read.book_read_rsvps.going.where(reminder_sent_at: nil).includes(:user, :book_read).find_each do |rsvp|
        begin
          UserMailer.with(rsvp: rsvp, time_zone: Time.zone.name).book_read_reminder_email.deliver_now
          rsvp.update!(reminder_sent_at: Time.current)
        rescue => e
          logger.error("Failed to send reminder for RSVP #{rsvp.id}: #{e.message}")
        end
      end
    end
  end
end
