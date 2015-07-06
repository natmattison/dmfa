require 'sinatra'
require 'json'
require 'yaml'
require 'httparty'
require 'sinatra/activerecord'
require 'slim'
require 'aws/s3'
require 'carrierwave'
require 'fog'
require 'mini_magick'
require 'carrierwave/orm/activerecord'

# CarrierWave.configure do |config|
#   bucket = ENV['S3_BUCKET_NAME']
#   config.fog_credentials = {
#     :provider               => 'AWS',                        # required
#     :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],                        # required
#     :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],                        # required
#     :region                 => 'us-west-2',                  # optional, defaults to 'us-east-1'
#     :host                   => 's3-us-west-2.amazonaws.com',             # optional, defaults to nil
#   }
#   config.storage = :fog
#   config.fog_directory  = bucket                     # required
#   config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
# end

require_relative './models'

class Dmfa < Sinatra::Application
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

  get '/' do
    slim :index
  end

  get '/about' do
    @about_active = "active"
    slim :about
  end

  get '/reproductions' do
    @reproductions_active = "active"
    slim :reproductions
  end
  
  get '/contact' do
    @contact_active = "active"
    slim :contact
  end
  
  post '/contact' do
    # from http://ididitmyway.herokuapp.com/past/2010/12/4/an_email_contact_form_in_sinatra/
    require 'pony'
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => ENV['TO_EMAIL'],
      :bcc => ENV['BCC_EMAIL'],
      :subject => params[:name] + " has contacted you from debbiemattisonfineart.com",
      :body => params[:message],
      :port => '587',
      :via => :smtp,
      :via_options => { 
        :address              => 'smtp.sendgrid.net', 
        :port                 => '587', 
        :enable_starttls_auto => true, 
        :user_name            => ENV['SENDGRID_USERNAME'], 
        :password             => ENV['SENDGRID_PASSWORD'], 
        :authentication       => :plain, 
        :domain               => ENV['SENDGRID_DOMAIN']
      })
    redirect '/success' 
  end

  get '/success' do
    @contact_active = "active"
    slim :success
  end

  get '/gallery-old' do
    @gallery_active = "active"
    categories = Painting.pluck(:category).uniq
    @samples = categories.map {|c| [c, Painting.where(category: c).first(4)] }
    slim :gallery
  end

  get '/gallery' do
    @gallery_active = "active"
    @categories = Painting.pluck(:category).uniq
    @samples = @categories.map {|c| [c, Painting.where(category: c)] }
    slim :gallery_all
  end

  get '/gallery/:category' do
    @gallery_active = "active"
    @category = params[:category]
    @paintings = Painting.where('category ILIKE ?', @category)
    @category = "Nothing in this category." if @paintings.empty?
    slim :gallery_cat
  end

  get '/detail/:id' do
    @gallery_active = "active"
    @painting = Painting.find_by_id(params[:id])
    @url = @painting.image_url
    unless @painting
      status 404
      return "Can't find that"
    end
    slim :detail
  end
  
  get '/supersecret-admin' do
    @mediums = ['Oil', 'Acrylic']
    @categories = ['Landscape', 'Portrait', 'Still Life', 'Study']
    slim :admin
  end
  
  post '/painting/new' do
    unless params[:password] == ENV['ADMIN_PASS']
      status 400
      return 'unauthorized'
    end    
    file       = params['image'][:tempfile]
    filename   = params['image'][:filename]
    
    bucket = ENV['S3_BUCKET_NAME']
    
    s3_url = nil

    name = params[:name]
    length = params[:length]
    width = params[:width]
    sold = params[:sold]
    description = params[:description]
    category = params[:category]
    medium = params[:medium]
    image = params[:image]
    s3_url = s3_url
    painting = Painting.new(name: name, length: length, width: width, sold: sold, description: description, category: category, medium: medium, s3_url: s3_url, image: image)
    painting.save!
    status 200
    body 'ok'
  end
  
  post '/painting/delete' do
    unless params[:password] == ENV['ADMIN_PASS']
      status 400
      return 'unauthorized'
    end
    p = Painting.find_by_id(params[:id])
    p.destroy! if p
    # TODO delete from s3 d'oh
    status 200
    body 'ok'
  end
  
  get '/update/:id' do
    @p = Painting.find_by_id(params[:id])
    unless @p
      status 400
      return "can't find that"
    end

    @mediums = ['Oil', 'Acrylic']
    @categories = ['Landscape', 'Portrait', 'Still Life', 'Study']

    slim :update
  end
  
  post '/painting/update/:id' do
    p = Painting.find_by_id(params[:id])
    unless p
      status 400
      return "can't find that"
    end
    p.name = params[:name] ? params[:name] : p.name
    p.length = params[:length] ? params[:length] : p.length
    p.width = params[:width] ? params[:width] : p.width
    # todo: figure out
    # p.s3_url = params[:s3_url] ? params[:s3_url] : p.s3_url
    p.category = params[:category] ? params[:category] : p.category
    p.medium = params[:medium] ? params[:medium] : p.medium
    p.description = params[:description] ? params[:description] : p.description
    p.sold = params[:sold] ? params[:sold] : p.sold
    p.save!
    status 200
    body 'updated!'
  end

  run! if app_file == $0

end
