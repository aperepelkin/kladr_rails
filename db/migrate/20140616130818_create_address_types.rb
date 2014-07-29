class CreateAddressTypes < ActiveRecord::Migration
  def change
    create_table :address_types do |t|
      t.integer :level
      t.string :name
      t.string :description
      t.integer :code

      t.timestamps
    end
  end
end
