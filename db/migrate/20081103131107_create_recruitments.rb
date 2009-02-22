class CreateRecruitments < ActiveRecord::Migration
  def self.up
    create_table :recruitments, :force => true do |t|
      t.belongs_to :employee
      t.string :joblevel, :default => 'unspecified', :null => false, :limit => 100
      t.string :status, :default => 'first_stage', :null => false, :limit => 100
      t.string :prev_status, :default => '', :null => false, :limit => 100
      t.datetime :status_change_at, :null => false, :default => Time.now
      t.string :rejected_by, :default => 'unspecified', :null => false, :limit => 100
      t.text :notes, :limit => 10000, :default => ''
      t.integer :documents_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :recruitments
    add_index :recruitments, [:id, :status]
  end

  def self.down
    drop_table :recruitments
    remove_index :recruitments, [:id, :status]
  end
end