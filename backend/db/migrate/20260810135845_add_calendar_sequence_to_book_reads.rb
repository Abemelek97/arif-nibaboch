class AddCalendarSequenceToBookReads < ActiveRecord::Migration[8.0]
  def change
    add_column :book_reads, :calendar_sequence, :integer, default: 0, null: false
  end
end
