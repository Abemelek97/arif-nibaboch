class SendBookReadRemindersJob < ApplicationJob
  queue_as :default
  REMINDER_WINDOW = 24.hours
  CLAIM_LEASE_TIMEOUT = 10.minutes

  def perform
    upcoming_reads = BookRead.where(meetup_time: Time.current..(Time.current + REMINDER_WINDOW))
    upcoming_reads.find_each do |book_read|
      book_read.book_read_rsvps.going.where(reminder_sent_at: nil).includes(:user, :book_read).find_each do |rsvp|
        next unless claim_rsvp(rsvp)

        begin
          UserMailer.with(rsvp: rsvp, time_zone: Time.zone.name).book_read_reminder_email.deliver_now
          rsvp.update_column(:reminder_sent_at, Time.current)
        rescue => e
          logger.error("Failed to send reminder for RSVP #{rsvp.id}: #{e.message}")
          rsvp.update_column(:reminder_claimed_at, nil)
        end
      end
    end
  end

  private

  def claim_rsvp(rsvp)
    rows = BookReadRsvp.where(id: rsvp.id)
      .where(reminder_sent_at: nil)
      .where("reminder_claimed_at IS NULL OR reminder_claimed_at < ?", CLAIM_LEASE_TIMEOUT.ago)
      .update_all(reminder_claimed_at: Time.current)
    rows == 1
  end
end
