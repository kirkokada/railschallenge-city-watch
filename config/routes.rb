Rails.application.routes.draw do
  resources :emergencies, except: [:edit, :new],
                          defaults: { format: :json }

  resources :responders, except:   [:edit, :new],
                         defaults: { format: :json }

  match '*path', to: 'errors#catch_404', via: :all
end
