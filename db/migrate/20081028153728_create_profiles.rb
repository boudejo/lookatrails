class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.belongs_to :user
      t.string :first_name, :limit => 100, :default => '', :null => true
      t.string :last_name, :limit => 100, :default => '', :null => true
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :profiles
    add_index :profiles, [:id, :user_id], :unique => true
    add_index :profiles, [:id, :deleted_at]
  end

  def self.down
    drop_table :profiles
    remove_index :profiles, [:id, :user_id]
    add_index :profiles, [:id, :deleted_at]
  end
end