class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes, id: false do |t|
      t.string     :id,  null: false
      t.belongs_to :bus, index: true
      t.string     :day, null: false
      t.timestamps
    end

    add_index :routes, :id, unique: true
  end
end
