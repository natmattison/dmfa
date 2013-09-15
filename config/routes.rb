Dmfa::Application.routes.draw do
  
  get '/' => 'application#index', as: 'index'
  get 'gallery/' => 'application#gallery', as: 'gallery'
  get 'gallery/:id' => 'application#artwork', as: 'artwork'
  get '/about' => 'application#about', as: 'about' 
  get '/giclees' => 'application#giclees', as: 'giclees'
  get '/commissions' => 'application#commissions', as: 'commissions'
  get '/contact' => 'application#contact', as: 'contact'

end
