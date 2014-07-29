class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :name
      t.string :socr
      t.string :code
      t.string :index
      t.string :gninmb
      t.string :uno
      t.string :ocatd
      t.integer :status
      t.integer :parent_id
      t.integer :old_id
      t.references :address_type
      t.string :subject_code
      t.string :region_code
      t.string :city_code
      t.string :settlement_code
      t.string :active_code
      t.string :clean_code
      t.boolean :active

      t.timestamps
    end
  end
end
