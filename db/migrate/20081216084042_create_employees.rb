class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees, :force => true do |t|
      t.belongs_to :identity
      t.string :code, :limit => 3, :default => '', :null => true
      t.string :fullcode, :limit => 9, :default => '', :null => true
      t.string :function, :limit => 100, :default => 'consultant', :null => true
      t.string :joblevel, :default => 'unspecified', :null => false, :limit => 100
      t.date :date_in_service, :null => true
      t.date :date_out_service, :null => true
      t.date :date_oresys, :null => true
      t.string :workshedule, :default => 'fulltime', :null => false, :limit => 100
      t.string :bank_account_number, :null => true, :limit => 100
      t.string :status, :default => 'not_active', :null => false, :limit => 100
      t.string :prev_status, :default => 'not_active', :null => false, :limit => 100
      t.datetime :status_change_at, :null => false, :default => Time.now
      t.text :status_notes, :limit => 2000, :default => ''
      t.text :notes, :limit => 10000, :default => ''
      t.integer :addresses_count, :default => 0
      t.integer :communications_count, :default => 0
      t.integer :documents_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :employees
    add_index :employees, [:id, :code]
    add_index :employees, [:id, :status]
    add_index :employees, [:id, :code, :status]
  end

  def self.down
    drop_table :employees
    remove_index :employee, [:id, :code]
    remove_index :employee, [:id, :status]
    remove_index :employee, [:id, :code, :status]
  end
end
