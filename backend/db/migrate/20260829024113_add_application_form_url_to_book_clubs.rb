class AddApplicationFormUrlToBookClubs < ActiveRecord::Migration[8.0]
  def change
    add_column :book_clubs, :application_form_url, :string
  end
end
