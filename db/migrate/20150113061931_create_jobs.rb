class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :company_id
      t.integer :jobsdb_id

      t.string :position_name
      t.string :position_type #full time or part time
      t.integer :monthly_salary
      t.string :location
      t.text :position_about

      t.timestamps
    end
  end
end
