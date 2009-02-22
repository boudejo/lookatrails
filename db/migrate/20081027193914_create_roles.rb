class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true do |t|
      t.string :name
    end
    myisam :roles
    
    # generate the join table
    create_table :roles_users, :id => false do |t|
      t.integer :role_id
      t.integer :user_id
    end
    myisam :roles_users
    add_index :roles_users, [:role_id, :user_id]
  end

  def self.down
    drop_table :roles
    drop_table :roles_users
    remove_index :roles_users, [:role_id, :user_id]
  end
end