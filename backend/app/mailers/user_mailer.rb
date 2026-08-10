class UserMailer < ApplicationMailer
  default from: "#{Rails.configuration.x.app_name} <noreply@#{Rails.configuration.x.mail_from_domain}>" # this domain must be verified with Resend

  def rsvp_confirmation
    @rsvp = params[:rsvp]
    @user = @rsvp.user
    @book_read = @rsvp.book_read

    # Use the passed time_zone or default to Taipei (UTC+8)
    @time_zone = params[:time_zone] || "Taipei"

    cal = Icalendar::Calendar.new
    cal.ip_method = "REQUEST"
    cal.event do |e|
      e.uid         = calendar_event_uid
      e.sequence    = @book_read.calendar_sequence || 0
      # Explicitly marking as UTC ensures calendars auto-adjust to user's local time
      e.dtstart     = Icalendar::Values::DateTime.new(@book_read.meetup_time.utc, tzid: "UTC")
      e.dtend       = Icalendar::Values::DateTime.new((@book_read.meetup_time + 2.hours).utc, tzid: "UTC")
      e.summary     = "Book Read: #{@book_read.book&.title || 'Discussion'}"
      e.description = "RSVP for #{@book_read.book_club.name}"
      e.location    = @book_read.meetup_location
      e.ip_class    = "PRIVATE"
      e.status      = "CONFIRMED"
    end

    attachments["invite.ics"] = {
      mime_type: "text/calendar; method=REQUEST",
      content: cal.to_ical
    }

    mail(to: @user.email, subject: "RSVP Confirmation: #{@book_read.book&.title || 'Book Read'}")
  end

  def book_read_updated_invite
    @rsvp = params[:rsvp]
    @user = @rsvp.user
    @book_read = @rsvp.book_read

    @time_zone = params[:time_zone] || "Taipei"

    cal = Icalendar::Calendar.new
    cal.ip_method = "REQUEST"
    cal.event do |e|
      e.uid         = calendar_event_uid
      e.sequence    = @book_read.calendar_sequence || 0
      e.dtstart     = Icalendar::Values::DateTime.new(@book_read.meetup_time.utc, tzid: "UTC")
      e.dtend       = Icalendar::Values::DateTime.new((@book_read.meetup_time + 2.hours).utc, tzid: "UTC")
      e.summary     = "Updated: Book Read: #{@book_read.book&.title || 'Discussion'}"
      e.description = "RSVP for #{@book_read.book_club.name} (Schedule Updated)"
      e.location    = @book_read.meetup_location
      e.ip_class    = "PRIVATE"
      e.status      = "CONFIRMED"
    end

    attachments["invite.ics"] = {
      mime_type: "text/calendar; method=REQUEST",
      content: cal.to_ical
    }

    mail(to: @user.email, subject: "[Updated] Book Read: #{@book_read.book&.title || 'Book Read'}")
  end

  private

  def calendar_event_uid
    mail_domain = Rails.configuration.x.mail_from_domain
    "book-read-#{@book_read.id}-rsvp-#{@rsvp.id}@#{mail_domain}"
  end
end
