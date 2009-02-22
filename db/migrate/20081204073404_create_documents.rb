class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.references :documentable, :polymorphic => true
      t.string :document_file_name, :limit => 255, :default => '', :null => true
      t.string :document_content_type, :limit => 255, :default => '', :null => true
      t.integer :document_file_size
      t.datetime :document_updated_at, :null => true
      t.text :notes, :limit => 10000, :default => ''
      t.archiveable
      t.timestamps
      t.userstamps(true)      
    end
    myisam :documents
    add_index :documents, [:id, :documentable_id, :documentable_type]
  end

  def self.down
    drop_table :documents
    remove_index :documents, [:id, :documentable_id, :documentable_type]
  end
end