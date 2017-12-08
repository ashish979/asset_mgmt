Rails4::Application.routes.draw do
 
  resources :companies, :except => [:destroy, :show] do 
    member do 
      put :change_status
    end
  end

  scope(path: "(:current_company)") do 
    as :employee do
      match '/employee/confirmation' => 'confirmations#update', :via => :put, :as => :update_employee_confirmation
    end
    
    devise_for :employees, :controllers => { :confirmations => "confirmations" }
    
    get "employees(/:type)", :controller => :employees, :action => :index, :type => /enabled|disabled/, :as => :employees

    resources :employees, :except => :index do
      get :autocomplete_employee_name, :on => :collection
      get 'password/reset', :action => 'edit_password', :on => :collection
      put :update_password, :on => :collection
      get :assignment_report, :on => :collection
      member do
        put :disable
        put :enable
      end 
    end

    resources :assets, :path => "assets", :only => [:new, :create] do 
      member do 
        put :uploaded_files
      end
      collection do 
        get :autocomplete_tag_name
        get :autocomplete_assets_name
        get :autocomplete_asset_vendor
        get :autocomplete_asset_brand
      end
    end
    
    get "/assets(/:type)", to: "assets#index", :as => :assets_list

    resources :asset_types do 
      resources :assets do
        collection do
          get :change_form_content
          get :assign
        end
        member do
          delete :remove_tag
          put :retire_asset
        end 
        resources :assignments, :only => [:new, :create]
      end
    end

    resources :property_groups, :except => [:edit, :update] do 
      resources :properties, :only => [:create, :destroy]
    end


    resources :comments, :only => [:create, :destroy, :show]
    
    resources :asset_properties, :except => :index do 
      get :autocomplete_property_name, :on => :collection
    end

    resources :assignments do
      collection do
        get :change_aem_form
        get :populate_asset
      end
    end
    
    get "tickets(/:state)", :controller => :tickets, :action => :index, :state => /closed|open/, :as => :tickets
    get "/asset_types/:id/asset/:id/tickets", :to => "assets#tickets", :as => "asset_tickets"
    
    resources :tickets, :except => [:destroy, :edit, :update] do 
      member do 
        put :change_state
      end
      collection do 
        get :search
      end
    end
    resources :file_uploads, :only => :destroy  

    get "/:id/asset_properties", :to => "asset_properties#index", :as => "asset_properties_index"    
    get ":type/:id/return", :to => "assignments#return_asset", :as => "return_asset"
    get ":type/:id/histories", :to => "histories#index", :as => "histories"
    get 'show_tag', :to => "home#show_tag", :as => :show_tag
    get 'search', :to => "home#search", :as => :search
    get "asset_type/:asset_type_id/asset/:id/return", :to => "assignments#return_asset", :as => "return_asset_type_asset"

    authenticated :employee do
      root :to => "home#index"
    end

    unauthenticated :employee do
      devise_scope :employee do 
        get "/" => "devise/sessions#new"
      end
    end
  end
  
end
