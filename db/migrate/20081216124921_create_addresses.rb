class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string  :label, :limit => 50, :default => 'Home', :null => true
      t.boolean :main, :default => false
      t.references :addressable, :polymorphic => true
      t.string  :address_line1, :limit => 255, :default => '', :null => true
      t.string  :address_line2, :limit => 255, :default => '', :null => true
      t.string  :address_nr, :limit => 10, :default => '', :null => true
      t.string  :address_bus, :limit => 5, :default => '', :null => true
      t.string  :address_postal, :limit => 20, :default => '', :null => true
      t.string  :address_place, :limit => 255, :default => '', :null => true
      t.string  :address_country, :limit => 100, :default => '', :null => true
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :addresses
    add_index :addresses, [:id, :addressable_id, :addressable_type]
  end

  def self.down
    drop_table :addresses
    remove_index :addresses, [:id, :addressable_id, :addressable_type]
  end
end
