class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :vat_number, :limit => 50, :default => '', :null => true
      t.string :kvk_number, :limit => 8, :default => '', :null => true
      t.string :bankaccount_number, :limit => 50, :default => '', :null => true
      t.string :iban_number, :limit => 34, :default => '', :null => true
      t.string :bic_number, :limit => 11, :default => '', :null => true
      t.integer :legaltype, :limit => 2, :default => 0, :null => false
      t.text :notes, :limit => 5000, :default => ''
      t.integer :contacts_count, :default => 0
      t.integer :opportunities_count, :default => 0
      t.integer :projects_count, :default => 0
      t.integer :documents_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :accounts
  end

  def self.down
    drop_table :accounts
  end
end
