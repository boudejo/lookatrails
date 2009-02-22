class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :login,                     :string, :limit => 40
      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :state,                     :string, :null => :no, :default => 'passive'
      t.references :loginable,             :polymorphic => true
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :users
    add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
    add_index :users, [:id, :deleted_at]
    add_index :users, [:loginable_id, :loginable_type]
  end

  def self.down
    drop_table :users
    remove_index :users, :login
    remove_index :users, :email
    remove_index :users, [:id, :deleted_at]
    remove_index :users, [:loginable_id, :loginable_type]
  end
end