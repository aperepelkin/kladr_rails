class Street < ActiveRecord::Base

  validates :code, :uniqueness => true
  validates :code, :name, :parent_id, :address_type_id, :presence => true

  belongs_to :parent, :class_name => 'Area', :foreign_key => :parent_id
  belongs_to :old, :class_name => 'Street', :foreign_key => :old_id
  belongs_to :address_type

  has_many :buildings

end
