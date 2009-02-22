class CreateCars < ActiveRecord::Migration
  def self.up
    create_table :cars, :force => true do |t|
      t.string :license_plate, :limit => 50
      t.belongs_to :employee
      t.string :employee_code, :limit => 255, :default => '', :null => true
      t.string :status, :default => 'unassigned', :null => false, :limit => 100
      t.string :prev_status, :default => '', :null => false, :limit => 100
      t.datetime :status_change_at, :null => false, :default => Time.now
      t.string :brand, :limit => 100
      t.decimal :budget, :precision => 6, :scale => 2
      t.date :in_service_date, :null => true
      t.text :notes, :limit => 5000, :default => ''
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :cars
    add_index :cars, :license_plate, :unique => true
    add_index :cars, [:id, :employee_id]
  end

  def self.down
    drop_table :cars
    remove_index :cars, :license_plate
    remove_index :cars, [:id, :employee_id]
  end
end
