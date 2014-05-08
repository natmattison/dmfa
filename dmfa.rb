require 'sinatra'
require 'json'
require 'yaml'
require 'httparty'
require 'sinatra/activerecord'
require 'slim'

require_relative './models'

DB_CONFIG = YAML.load_file('database.yml')

class Dmfa < Sinatra::Application
  set :database, "postgres://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"

  get '/' do
    slim :index
  end

# 404.html  about.html  base.html  commissions.html  contact.html  detail.html  error.html  gallery.html  index.html  reproductions.html  test.html

  get '/about' do
    slim :index
  end

  get '/reproductions' do
    slim :reproductions
  end
  
  get '/contact' do
    slim :contact
  end  

  get '/gallery' do
    slim :gallery
  end
  
  get '/detail/:id' do
    @painting = Painting.find(params[:id])
    slim :detail
  end

  run! if app_file == $0

end
