class AddSold < ActiveRecord::Migration
  def up
    add_column :paintings, :sold, :boolean
  end

  def down
  end
end
