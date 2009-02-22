class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :function, :limit => 100, :default => '', :null => true
      t.string :department, :limit => 100, :default => '', :null => true
      t.text :notes, :limit => 5000, :default => ''
      t.integer :opportunities_count, :default => 0
      t.integer :projects_count, :default => 0
      t.integer :documents_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :contacts
  end

  def self.down
    drop_table :contacts
  end
end
