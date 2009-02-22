class CreateOpportunities < ActiveRecord::Migration
  def self.up
    create_table :opportunities do |t|
      t.string :name, :limit => 255, :default => '', :null => true
      t.belongs_to :account
      t.belongs_to :bdm
      t.belongs_to :contact
      t.references :project  
      t.string :status, :default => 'pending', :null => false, :limit => 100
      t.string :prev_status, :default => '', :null => false, :limit => 100
      t.datetime :status_change_at, :null => false, :default => Time.now
      t.date :start_date, :null => true
      t.date :end_date, :null => true
      t.decimal :daily_price, :null => true, :default => 0.00, :precision => 10, :scale => 2
      t.string :probability, :default => '25%', :null => false
      t.string :costcenter, :default => 'unspecified', :null => false
      t.string :billingmethod, :default => 'unspecified', :null => false, :limit => 100
      t.decimal :budget, :precision => 12, :scale => 2, :default => 0.00
      t.string :option, :default => 'option_1', :null => false, :limit => 100
      t.decimal :perc_work, :null => true, :default => 100.00, :precision => 5, :scale => 2
      t.integer :fte, :default => 1
      t.integer :max_days, :default => 1
      t.text :notes, :limit => 15000, :default => ''
      t.integer :documents_count, :default => 0
      t.integer :resources_count, :default => 0
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :opportunities
    add_index :opportunities, [:id, :account_id]
    add_index :opportunities, [:id, :contact_id]
    add_index :opportunities, [:id, :bdm_id]
    add_index :opportunities, [:id, :account_id, :contact_id]
    add_index :opportunities, [:id, :account_id, :bdm_id]
  end

  def self.down
    drop_table :opportunities
    remove_index :opportunities, [:id, :account_id]
    remove_index :opportunities, [:id, :contact_id]
    remove_index :opportunities, [:id, :bdm_id]
    remove_index :opportunities, [:id, :account_id, :bdm_id]
  end
end
