class CreateCalendars < ActiveRecord::Migration
  def self.up
    create_table :calendars do |t|
      t.integer :year, :default => Time.now.year
      t.text :description, :limit => 5000, :default => ''
      t.integer :calendar_entries_count, :default => 0
      t.integer :workday_count, :default => 0
      t.integer :general_leave_count, :default => 0
      t.integer :holiday_count, :default => 0
      t.integer :postponed_holiday_count, :default => 0
      t.integer :event_special_day_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :calendars
    add_index :calendars, [:id, :year]
  end

  def self.down
    drop_table :calendars
    remove_index :calendars, [:id, :year]
  end
end