require 'pg'
require 'csv'

csv = CSV.read("paintings.csv", :headers => true)

csv_hash = csv.map(&:to_hash)

conn = PG.connect(host: ENV['DB_HOST'], port: ENV['DB_PORT'], user: ENV['DB_USER'], password: ENV['DB_PASSWORD'], dbname: ENV['DB_NAME'])

conn.exec('DELETE FROM paintings')

csv_hash.each do |row|
  begin
    id = row['id']
    name = row['name']
    description = row['description'] || ""
    height = row['height']
    width = row['width']
    sold = row['sold'] == 'y'
    category = row['category'].downcase
    medium = row['medium'].downcase
    thumbnail_url = row['thumbnail_url'].gsub('www.dropbox.com', 'dl.dropboxusercontent.com')
    fullsize_url = row['fullsize_url'].gsub('www.dropbox.com', 'dl.dropboxusercontent.com')
    price = row['price'] || nil
    if price && price.include?("$")
       price = price.sub(/.*\$/, '') 
    end
    showcase = row['showcase?'] == 'y'

    puts 'INSERT INTO paintings VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)' % [id, name, description, height, width, sold, category, medium, thumbnail_url, fullsize_url, price, showcase]

    conn.exec('INSERT INTO paintings VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)', [id, name, description, height, width, sold, category, medium, thumbnail_url, fullsize_url, price, showcase])
  rescue StandardError => e
    puts e
    next
  end
end
