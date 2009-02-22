class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.references :project
      t.references :opportunity
      t.references :employee
      t.decimal :day_price, :precision => 8, :scale => 2, :default => 0.00
      t.decimal :hour_price, :precision => 8, :scale => 2, :default => 0.00
      t.string :status, :default => 'shortlisted', :null => false, :limit => 100
      t.string :prev_status, :default => '', :null => false, :limit => 100
      t.datetime :status_change_at, :null => false, :default => Time.now
      t.text :notes, :limit => 15000, :default => ''
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :resources
    add_index :resources, [:id, :project_id, :employee_id]
    add_index :resources, [:id, :project_id]
    add_index :resources, [:id, :opportunity_id, :employee_id]
    add_index :resources, [:id, :opportunity_id]
  end

  def self.down
    drop_table :resources
    remove_index :resources, [:id, :project_id, :employee_id]
    remove_index :resources, [:id, :project_id]
    remove_index :resources, [:id, :opportunity_id, :employee_id]
    remove_index :resources, [:id, :opportunity_id]
  end
end
