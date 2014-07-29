class AddressType < ActiveRecord::Base

  validates :code, :description, :level, :name, :presence => true
  validates :code, :uniqueness => true
  validates_uniqueness_of :name, :scope => :level

end
