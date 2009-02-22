class CreateTimesheets < ActiveRecord::Migration
  def self.up
    create_table :timesheets do |t|
      t.belongs_to :employee
      t.integer :year, :default => Time.now.year
      t.integer :default_leave_days, :null => true, :default => 0
      t.integer :extra_leave_days, :null => true, :default => 0
      t.text :description, :limit => 5000, :default => ''
      t.integer :timesheet_entries_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :timesheets
    add_index :timesheets, [:id, :employee_id]
    add_index :timesheets, [:id, :employee_id, :year]
  end

  def self.down
    drop_table :timesheets
    remove_index :timesheets, [:id, :employee_id]
    remove_index :timesheets, [:id, :employee_id, :year]
  end
end