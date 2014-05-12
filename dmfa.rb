require 'sinatra'
require 'json'
require 'yaml'
require 'httparty'
require 'sinatra/activerecord'
require 'slim'

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
    @paintings = Painting.all
    slim :gallery
  end
  
  get '/detail/:id' do
    @gallery_active = "active"
    @painting = Painting.find(params[:id])
    slim :detail
  end
  
  post '/painting/new' do
    # check auth?

    name = params[:name]
    length = params[:length]
    width = params[:width]
    description = params[:description]
    s3_url = params[:s3_url]
    painting = Painting.new(name: name, length: length, width: width, description: description, s3_url: s3_url)
    painting.save!
    status 200
    body 'ok'
  end

  delete '/painting/:id' do
    # check auth?
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
    p.description = params[:description] ? params[:description] : p.description
    p.save!
    status 200
    body 'updated!'
  end

  run! if app_file == $0

end
