class Job < ActiveRecord::Base
  belongs_to :company
  validates :jobsdb_id, uniqueness: true
  serialize :position_about, Array
end
