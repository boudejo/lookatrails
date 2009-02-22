class Rating < ActiveRecord::Base
  belongs_to :ratable, :polymorphic => true
  belongs_to :rater, :polymorphic => true

  # For migration up
  def self.create_table #:nodoc:
    self.connection.create_table 'ratings' do |t|
      t.column :ratable_id, :integer
      t.column :ratable_type, :string
      t.column :rater_id, :integer
      t.column :rater_type, :string
      t.column :rating, :integer
    end
  end
  
  # For migration down
  def self.drop_table #:nodoc:
    self.connection.drop_table :ratings
  end
  
  def self.ratable_class(ratable)
    ActiveRecord::Base.send(:class_name_of_active_record_descendant, ratable.class).to_s
  end
  
  def self.rater_class(rater)
    ActiveRecord::Base.send(:class_name_of_active_record_descendant, rater.class).to_s
  end
  
  def self.find_ratable(rated_class, rated_id)
    rated_class.constantize.find(rated_id)
  end

  def self.find_rater(rater_class, rater_id)
    rater_class.constantize.find(rater_id)
  end
  
end