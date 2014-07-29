# This migration comes from kladr (originally 20140618132435)
class AddLevelToAreas < ActiveRecord::Migration
  def change
    add_column :areas, :level, :integer
    Area.connection.update_sql(
        'update areas inner join address_types on areas.address_type_id = address_types.id
            set areas.level = address_types.level')
  end
end
