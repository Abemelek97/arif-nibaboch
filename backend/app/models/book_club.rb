class BookClub < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true

  has_one_attached :cover_photo
  has_one_attached :photo

  def name_initial
    name.presence&.strip&.first&.upcase || "B"
  end

  has_many :book_reads, dependent: :destroy
  has_many :books, through: :book_reads
  has_many :book_club_members, dependent: :destroy
  has_many :members, through: :book_club_members, source: :user

  MAX_PHOTO_SIZE = 5.megabytes
  ALLOWED_PHOTO_TYPES = %w[image/jpeg image/jpg image/png image/webp image/gif].freeze

  validates :name, presence: true
  validates :application_form_url,
            format: { with: %r{\Ahttps?://\S+\z}, message: "must be a valid URL starting with http:// or https://" },
            allow_blank: true
  validate :acceptable_photo

  after_create :add_owner_as_admin

  def has_member?(user)
    return false unless user

    book_club_members.exists?(user: user)
  end

  private

  def acceptable_photo
    return unless photo.attached?

    if photo.content_type == "image/svg+xml" || photo.filename.to_s.downcase.end_with?(".svg")
      errors.add(:photo, "cannot be an SVG file for security reasons")
      return
    end

    unless ALLOWED_PHOTO_TYPES.include?(photo.content_type)
      errors.add(:photo, "must be a JPEG, PNG, WEBP, or GIF image")
      return
    end

    if photo.blob.byte_size > MAX_PHOTO_SIZE
      errors.add(:photo, "is too large (maximum size is 5MB)")
    end
  end

  def add_owner_as_admin
    if owner.present?
      book_club_members.create!(user: owner, role: :admin)
    end
  end
end
