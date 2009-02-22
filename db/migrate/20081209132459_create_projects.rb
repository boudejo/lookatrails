class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name, :limit => 255, :default => '', :null => true
      t.belongs_to :account
      t.integer :documents_count, :default => 0
      t.integer :resources_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :projects
    add_index :projects, [:id, :account_id]
  end

  def self.down
    drop_table :projects
    remove_index :projects, [:id, :account_id]
  end
end
