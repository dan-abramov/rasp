class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
      t.belongs_to :bus, index: true
      t.timestamps
    end
  end
end
