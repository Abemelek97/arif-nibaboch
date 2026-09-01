class CreateMembershipRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :membership_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book_club, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.text :note

      t.timestamps
    end
    add_index :membership_requests, [ :user_id, :book_club_id ], unique: true
  end
end
