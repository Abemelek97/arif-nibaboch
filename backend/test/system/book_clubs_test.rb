require "application_system_test_case"

class BookClubsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @club = book_clubs(:one)
    login_as @user
  end

  test "toggling private shows and enables the application form url field" do
    visit edit_book_club_path(@club)

    assert_no_selector "div[data-conditional-fields-target='field']", visible: true
    assert_selector "input[name='book_club[application_form_url]'][disabled]", visible: :all

    find("input[name='book_club[is_private]']").check

    assert_selector "div[data-conditional-fields-target='field']", visible: true
    assert_no_selector "input[name='book_club[application_form_url]'][disabled]", visible: :all

    fill_in "Application Form URL", with: "https://docs.google.com/forms/d/abc123"
    click_on "Update Club"

    assert_text "Book Club updated successfully"
    @club.reload
    assert @club.is_private
    assert_equal "https://docs.google.com/forms/d/abc123", @club.application_form_url
  end

  private

  def login_as(user)
    visit profile_path
    if page.has_button?("Sign out")
      click_on "Sign out"
    end
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_on "Log in"
  end
end
