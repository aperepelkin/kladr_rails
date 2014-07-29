class Building < ActiveRecord::Base

  validates :code, :uniqueness => true
  validates :code, :name, :parent_id, :address_type_id, :presence => true

  belongs_to :parent, :class_name => 'Street', :foreign_key => :parent_id
  belongs_to :old, :class_name => 'Building', :foreign_key => :old_id
  belongs_to :address_type

end
