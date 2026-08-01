require "test_helper"

class BookClubTest < ActiveSupport::TestCase
  test "automatically adds owner as admin upon creation" do
    owner = users(:one)

    club = BookClub.create!(
      name: "Test Club",
      owner: owner
    )

    membership = club.book_club_members.find_by(user: owner)

    assert_not_nil membership, "Owner should have a membership record"
    assert membership.admin?, "Owner should have the admin role"
  end

  test "rejects photo with invalid content type" do
    owner = users(:one)
    club = BookClub.new(name: "Invalid Type Club", owner: owner)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("some file content"),
      filename: "document.pdf",
      content_type: "application/pdf"
    )
    club.photo.attach(blob)

    assert_not club.valid?
    assert_includes club.errors[:photo], "must be a JPEG, PNG, WEBP, or GIF image"
  end

  test "explicitly rejects SVG photo for security reasons" do
    owner = users(:one)
    club = BookClub.new(name: "SVG Club", owner: owner)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("<svg></svg>"),
      filename: "logo.svg",
      content_type: "image/svg+xml"
    )
    club.photo.attach(blob)

    assert_not club.valid?
    assert_includes club.errors[:photo], "cannot be an SVG file for security reasons"
  end

  test "rejects photo exceeding maximum byte size" do
    owner = users(:one)
    club = BookClub.new(name: "Large Photo Club", owner: owner)

    oversized_data = "x" * (5.megabytes + 100)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(oversized_data),
      filename: "huge.jpg",
      content_type: "image/jpeg"
    )
    club.photo.attach(blob)

    assert_not club.valid?
    assert_includes club.errors[:photo], "is too large (maximum size is 5MB)"
  end

  test "accepts valid JPEG or PNG photo within size limits" do
    owner = users(:one)
    club = BookClub.new(name: "Valid Photo Club", owner: owner)

    valid_data = "fake image bytes"
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(valid_data),
      filename: "avatar.png",
      content_type: "image/png"
    )
    club.photo.attach(blob)

    assert club.valid?
  end
end
