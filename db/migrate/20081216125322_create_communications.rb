class CreateCommunications < ActiveRecord::Migration
  def self.up
    create_table :communications do |t|
      t.string :kind,   :limit => 100, :default => '', :null => true
      t.string :label,  :limit => 50, :default => '', :null => true
      t.string :value,  :limit => 100, :default => '', :null => true
      t.string :desc,   :limit => 100, :default => '', :null => true
      t.integer :rank,   :limit => 3, :null => true
      t.boolean :deleteable, :default => false
      t.boolean :editable, :default => true
      t.references :communicatable, :polymorphic => true
      t.timestamps
    end
    myisam :communications
    #add_index :communications, [:id, :communicatable_id, :communicatable_type]
  end

  def self.down
    drop_table :communications
    #remove_index :communications, [:id, :communicatable_id, :communicatable_type]
  end
end
