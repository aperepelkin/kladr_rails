# This migration comes from kladr (originally 20140618135749)
class AddIndexesOnArea < ActiveRecord::Migration
  def change
    add_index :areas, :code, unique: true
    add_index :areas, [:subject_code, :region_code, :city_code]
    add_index :areas, [:subject_code, :region_code]
    add_index :areas, [:subject_code]
  end
end
