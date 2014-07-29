class Area < ActiveRecord::Base

  validates :code, :uniqueness => true
  validates :code, :name, :address_type_id, :presence => true

  belongs_to :parent, :class_name => 'Area', :foreign_key => :parent_id
  belongs_to :old, :class_name => 'Area', :foreign_key => :old_id
  belongs_to :address_type

  has_many :streets

  default_scope -> { where(active: true) }

  scope :subjects, -> { where(region_code: '000', city_code: '000', settlement_code: '000') }
  scope :regions, -> { where(city_code: '000', settlement_code: '000').where("region_code <> '000'") }
  scope :cities, -> { where("city_code <> '000' or settlement_code <> '000' ") }
  scope :children_of, ->(parent_id) { where(parent_id: parent_id) }
  scope :level, ->(level) { where(level: level) }

end
