require "test_helper"

class PollVoteTest < ActiveSupport::TestCase
  def setup
    @poll_vote = poll_votes(:one)
  end

  test "should be valid with valid attributes" do
    assert @poll_vote.valid?
  end

  test "should require a poll_option" do
    @poll_vote.poll_option = nil
    assert_not @poll_vote.valid?
  end

  test "should require a user" do
    @poll_vote.user = nil
    assert_not @poll_vote.valid?
  end

  test "should prevent a user from voting twice for the same option" do
    duplicate_vote = @poll_vote.dup
    assert_not duplicate_vote.valid?
    assert_includes duplicate_vote.errors[:user_id], "has already voted for this option"
  end

  test "should allow a user to vote for multiple options in the same poll" do
    poll = polls(:one)
    user = users(:one)
    other_option = poll.poll_options.where.not(id: @poll_vote.poll_option_id).first

    multi_vote = PollVote.new(poll_option: other_option, user: user)
    assert multi_vote.valid?
  end

  test "should not allow voting after poll end date" do
    expired_poll = polls(:two)
    option = expired_poll.poll_options.create!(content: "Late vote option")
    late_vote = PollVote.new(poll_option: option, user: users(:one))

    assert_not late_vote.valid?
    assert_includes late_vote.errors[:poll], "has ended"
  end
end
