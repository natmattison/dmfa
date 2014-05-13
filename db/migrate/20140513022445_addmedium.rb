class Addmedium < ActiveRecord::Migration
  def up
    add_column :paintings, :medium, :string
    add_column :paintings, :category, :string
  end

  def down
  end
end
