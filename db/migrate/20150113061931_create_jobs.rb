class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :company_id
      t.string :jobsdb_id
      t.string :position_name
      t.text :position_about
      t.date :posted_when
      
      t.string :position_type #full time or part time
      t.integer :monthly_salary
      t.string :location

      t.timestamps
    end
  end
end
