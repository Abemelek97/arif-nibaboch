class HomeController < ApplicationController
  def index
  end

  def upcoming
    @upcoming_book_reads = BookRead.includes(:book, :book_club)
                                .where("meetup_time >= ?", Time.current).order(meetup_time: :desc)
    render partial: "home/upcoming_book_reads"
  end
end

