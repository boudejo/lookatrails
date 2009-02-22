class CreateTimesheetEntries < ActiveRecord::Migration
  def self.up
    create_table :timesheet_entries do |t|
      t.belongs_to :timesheet
      t.text :summary, :limit => 255, :default => ''
      t.datetime :start, :null => false
      t.datetime :end, :null => true
      t.string :status, :default => 'unspecified', :null => false, :limit => 100
      t.string :kind, :default => 'unspecified', :null => true, :limit => 100
      t.text :description, :limit => 5000, :default => ''
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :timesheet_entries
    add_index :timesheet_entries, [:id, :timesheet_id]
  end

  def self.down
    remove_index :timesheet_entries, [:id, :timesheet_id]
  end
end