class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes, id: false do |t|
      t.string :id,  null: false
      t.string :day, null: false
      t.string :bus_number, null: false
      t.string :title, null: false    
      t.timestamps
    end

    add_index :routes, :id, unique: true
  end
end
