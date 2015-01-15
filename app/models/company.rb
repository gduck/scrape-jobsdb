class Company < ActiveRecord::Base
  has_many :jobs
  validates :name, uniqueness: true

  def self.search(search)
    if search
      # this gets only users with company associations
      where('companies.name LIKE ?', "%#{search}%")
    else
      all
    end
  end


end
