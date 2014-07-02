require 'sinatra'
require 'json'
require 'yaml'
require 'httparty'
require 'sinatra/activerecord'
require 'slim'
require 'aws/s3'

require_relative './models'

# DB_CONFIG = YAML.load_file('database.yml')

class Dmfa < Sinatra::Application
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  # set :database, "postgres://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"

  get '/' do
    slim :index
  end

# 404.html  about.html  base.html  commissions.html  contact.html  detail.html  error.html  gallery.html  index.html  reproductions.html  test.html
# acrylic | oil
# categories <--
# 

  get '/about' do
    @about_active = "active"
    slim :about
  end

  get '/reproductions' do
    @reproductions_active = "active"
    slim :reproductions
  end
  
  get '/contact' do
    slim :contact
  end  

  get '/gallery' do
    @gallery_active = "active"
    # @paintings = Painting.all
    categories = Painting.pluck(:category).uniq
    @samples = categories.map {|c| [c, Painting.where(category: c).pluck(:s3_url).sample] }
    
    slim :gallery
  end

  get '/gallery/:category' do
    @gallery_active = "active"
    @category = params[:category]
    # @paintings = Painting.where(category: @category)
    @paintings = Painting.where('category ILIKE ?', @category)
    @category = "Nothing in this category." if @paintings.empty?
    slim :gallery_cat
  end

  get '/detail/:id' do
    @gallery_active = "active"
    @painting = Painting.find(params[:id])
    slim :detail
  end
  
  get '/supersecret-admin' do
    @mediums = ['Oil', 'Acrylic']
    @categories = ['Landscape', 'Portrait', 'Still Life', 'Study']
    slim :admin
  end
  
  post '/painting/new' do
    # i hate myself
    unless params[:password] == ENV['ADMIN_PASS']
      status 400
      return 'unauthorized'
    end    
    file       = params['image'][:tempfile]
    filename   = params['image'][:filename]
    
    bucket = ENV['S3_BUCKET_NAME']
    
    AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
    )
    
    AWS::S3::DEFAULT_HOST.replace('s3-us-west-2.amazonaws.com')
    
    AWS::S3::S3Object.store(
      filename,
      open(file.path),
      bucket,
      :access => :public_read
    )
    s3_url = "https://#{bucket}.s3.amazonaws.com/#{filename}"

    name = params[:name]
    length = params[:length]
    width = params[:width]
    description = params[:description]
    category = params[:category]
    medium = params[:medium]
    s3_url = s3_url
    # return status 500 unless name && length && width && description && category && medium && s3_url
    painting = Painting.new(name: name, length: length, width: width, description: description, category: category, medium: medium, s3_url: s3_url)
    painting.save!
    status 200
    body 'ok'
  end

  delete '/painting/:id' do
    # i hate myself
    unless params[:password] == ENV['ADMIN_PASS']
      status 400
      return 'unauthorized'
    end
    p = Painting.find(params[:id])
    p.destroy!
    # todo delete from s3 DERP!!!!!!
    status 200
    body 'ok'
  end
  
  post '/painting/delete' do
    # i hate myself
    unless params[:password] == ENV['ADMIN_PASS']
      status 400
      return 'unauthorized'
    end
    p = Painting.find(params[:id])
    p.destroy!
    status 200
    body 'ok'
  end
  
  post '/painting/update/:id' do
    p = Painting.find(params[:id])
    p.name = params[:name] ? params[:name] : p.name
    p.length = params[:length] ? params[:length] : p.length
    p.width = params[:width] ? params[:width] : p.width
    p.s3_url = params[:s3_url] ? params[:s3_url] : p.s3_url
    p.category = params[:category] ? params[:category] : p.category
    p.medium = params[:medium] ? params[:medium] : p.medium
    p.description = params[:description] ? params[:description] : p.description
    p.save!
    status 200
    body 'updated!'
  end

  run! if app_file == $0

end
