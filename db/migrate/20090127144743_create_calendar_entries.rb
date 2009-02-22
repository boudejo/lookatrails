class CreateCalendarEntries < ActiveRecord::Migration
  def self.up
    create_table :calendar_entries do |t|
      t.belongs_to :calendar
      t.text :summary, :limit => 255, :default => ''
      t.datetime :date, :null => false
      t.string :status, :default => 'unspecified', :null => false, :limit => 100
      t.string :kind, :default => 'workday', :null => true, :limit => 100
      t.text :description, :limit => 5000, :default => ''
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :calendar_entries
    add_index :calendar_entries, [:id, :calendar_id]
  end

  def self.down
    remove_index :calendar_entries, [:id, :calendar_id]
  end
end