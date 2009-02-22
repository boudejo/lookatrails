class CreateAccountcontactcards < ActiveRecord::Migration
  def self.up
    create_table :accountcontactcards do |t|
      t.string :first_name, :limit => 100, :default => '', :null => true
      t.string :last_name, :limit => 100, :default => '', :null => true
      t.references :accountcontactable, :polymorphic => true
      t.string :address_line1, :limit => 255, :default => '', :null => true
      t.string :address_line2, :limit => 255, :default => '', :null => true
      t.string :address_nr, :limit => 10, :default => '', :null => true
      t.string :address_bus, :limit => 5, :default => '', :null => true
      t.string :address_postal, :limit => 20, :default => '', :null => true
      t.string :address_place, :limit => 255, :default => '', :null => true
      t.string :address_country, :limit => 100, :default => '', :null => true
      t.string :email, :limit => 255
      t.string :phone, :limit => 255
      t.string :fax, :limit => 255
      t.string :website, :limit => 255
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :accountcontactcards
  end

  def self.down
    drop_table :accountcontactcards
  end
end

