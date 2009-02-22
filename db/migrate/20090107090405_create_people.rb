class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people, :force => true do |t|
      # PERSON PROPERTIES:
      t.string :first_name, :limit => 100, :default => '', :null => true
      t.string :last_name, :limit => 100, :default => '', :null => true
      t.references :identity, :polymorphic => true
      t.string :national_number, :limit => 13, :default => '', :null => true
      t.date :date_of_birth, :null => true
      t.string :place_of_birth, :limit => 255, :default => '', :null => true
      t.string :marital_status, :default => 'unspecified', :null => false, :limit => 100
      t.string :partner, :limit => 255, :default => 'unkown', :null => true
      t.date :date_of_birth_partner, :null => true
      t.integer :children_accounted, :limit => 2
      t.text :notes, :limit => 10000, :default => ''
      # MISC:
      t.integer :addresses_count, :default => 0
      t.integer :communications_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :people
    add_index :people, [:id, :identity_id, :identity_type]
  end

  def self.down
    drop_table :people
    remove_index :people, [:id, :identity_id, :identity_type]
  end
end
