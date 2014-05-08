class CreatePaintings < ActiveRecord::Migration
  def up
    create_table :paintings do |p|
      p.string :name
      p.text :description
      p.float :length
      p.float :width
      p.string :s3_url
    end
  end

  def down
  end
end
