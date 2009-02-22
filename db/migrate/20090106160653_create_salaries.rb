class CreateSalaries < ActiveRecord::Migration
  def self.up
    create_table :salaries, :force => true do |t|
      t.belongs_to :employee
      t.decimal :gross_salary, :precision => 10, :scale => 2, :default => 0.00
      t.decimal :rep_allowance, :precision => 10, :scale => 2, :default => 0.00
      t.decimal :group_insurance_perc, :precision => 10, :scale => 2, :default => 0.00
      t.decimal :car_budget, :precision => 6, :scale => 2, :default => 0.00
      t.decimal :dkv, :precision => 6, :scale => 2, :default => 0.00
      t.decimal :grand_total, :precision => 12, :scale => 2, :default => 0.00
      t.decimal :daily_cost, :precision => 8, :scale => 2, :default => 0.00
      t.boolean :current, :default => false
      t.text :notes, :limit => 5000, :default => ''
      t.archiveable
      t.timestamps
      t.userstamps(true)
    end
    myisam :salaries
    add_index :salaries, [:id, :employee_id]
  end

  def self.down
    drop_table :salaries
    remove_index :salaries, [:id, :employee_id]
  end
end
