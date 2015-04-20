Rails.application.routes.draw do
  resources :emergencies, except: [:edit, :new, :destroy],
                          defaults: { format: :json }

  resources :responders, except:   [:edit, :new, :destroy],
                         defaults: { format: :json }

  match '*path', to: 'errors#catch_404', via: :all
end
