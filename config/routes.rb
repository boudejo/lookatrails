ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.
    map.error   '/error',         :controller => 'application', :action => 'error'
    map.denied  '/access_denied', :controller => 'application', :action => 'access_denied'

  # Non RESTful routes for user management.
    map.user_troubleshooting        '/users/troubleshooting',                     :controller => 'users', :action => 'troubleshooting'
    map.user_forgot_password        '/users/forgot_password',                     :controller => 'users', :action => 'forgot_password'
    map.user_forgot_password_result '/users/forgot_password_result',              :controller => 'users', :action => 'forgot_password_result'
    map.user_reset_password         '/users/reset_password/:password_reset_code', :controller => 'users', :action => 'reset_password', :password_reset_code => nil
    map.user_forgot_login           '/users/forgot_login',                        :controller => 'users', :action => 'forgot_login'
    map.user_clueless               '/users/clueless',                            :controller => 'users', :action => 'clueless'

    map.resources :users
  
  # Authenication specific routes:
    map.resource :session
  
    map.signup    '/signup',                    :controller => 'users',     :action => 'new'
    map.activate  '/activate/:activation_code', :controller => 'users',     :action => 'activate', :activation_code => nil
    map.register  '/register',                  :controller => 'users',     :action => 'create'
    map.login     '/login',                     :controller => 'sessions',  :action => 'new'
    map.logout    '/logout',                    :controller => 'sessions',  :action => 'destroy'
  
  # Application specific routes:
  
    # REPORTING
    # map.home '/home', :controller => 'home', :action => 'index'
  
    # Dashboard
    map.dashboard '/pis/dashboard', :controller => 'pis/dashboard', :action => 'index'
    # Profiles
    map.my_profile  '/my_profile', :controller => 'profiles', :action => 'my_profile'
    map.resources :profiles, :member => {
                                        :my_profile => :get,
                                        :edit_password => :get,
                                        :update_password => :put,
                                        :edit_email => :get,
                                        :update_email => :put
                                        }
  
    #map.resources :people,  :member   => {:destroy => :delete, :delete => :get}
    #map.resources :calendar,  :member   => {:destroy => :delete, :delete => :get}
  
    # CRM
    map.namespace(:crm) do |crm|
      crm.resources :accounts,  :member   => {:destroy => :delete, :delete => :get}, 
                                :collection  => {:filter => :get},
                                :has_many => :documents do |accounts|
        accounts.resources :contacts, :member =>  {:destroy => :delete, :delete => :get}
      end
    
      crm.resources :contacts,  :member => {:destroy => :delete, :delete => :get}, 
                                :collection  => {:filter => :get}
                                
      crm.resources :opportunities, :member =>  {:destroy => :delete, :delete => :get},
                                    :has_many => [:resources, :documents]
    end

    # PIS
    map.namespace(:pis) do |app|
      app.root :controller => 'dashboard', :action => 'index'
      app.dashboard '/dashboard', :controller => APP.setting('app.default_controller'), :action => 'index'
      # HR
      app.resources :recruitments,  :member       => {:destroy => :delete, :delete => :get},
                                    :collection   => {:forecast => :get},
                                    :path_prefix  => "pis/hr", 
                                    :has_many     => :documents
                                    
      app.resources :employees,     :member       => {:destroy => :delete, :delete => :get}, 
                                    :path_prefix  => "pis/hr", 
                                    :collection   => {:filter_consultants => :get},
                                    :has_many     => [:salaries, :timesheets, :evaluations, :documents],
                                    :has_one      => [:person, :profile]
     
      app.resources :calendars,     :has_many     => [:calendar_entries]
                                    
      # PROJECTS
      app.resources :projects,      :member       => {:destroy => :delete, :delete => :get},
                                    :collection   => {:filter => :get},
                                    :has_many     => [:resources, :documents],
                                    :has_one      => [:planning]
                                    
      # MISC
        # CARS
        app.resources :cars, :member      => {:destroy => :delete, :delete => :get}, 
                             :collection  => {:filter => :get}
    end
  
  # Administration routes:
  
    map.namespace(:admin) do |admin|
      admin.root :controller => 'dashboard', :action => 'index'
      admin.dashboard '/dashboard', :controller => 'dashboard', :action => 'index'
      admin.resources :users, :member     => { :suspend   => :put,
                                               :unsuspend => :put,
                                               :activate  => :put, 
                                               :purge     => :delete,
                                               :reset_password => :put,
                                               :delete    => :get 
                                             },
                              :collection => { :pending   => :get,
                                               :active    => :get, 
                                               :suspended => :get, 
                                               :deleted   => :get
                                             }
    end

  # Global Application routes:
    map.changelog '/changelog', :controller => 'application', :action => 'changelog'
    
  # Set the default location
    map.root :controller => 'home', :action => 'index'
  
  # Install the default routes as the lowest priority.
    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'
end
