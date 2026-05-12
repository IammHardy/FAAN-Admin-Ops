Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  resources :departments
  resources :units
  resources :users
  resources :audit_logs, only: [:index, :show]

  resource :account, only: [:edit, :update]

  resources :notifications, only: [:index] do
    member do
      patch :mark_as_read
    end
  end

  resources :dispatches do
    member do
      patch :mark_dispatched
      patch :mark_received
      patch :mark_acknowledged
      patch :mark_filed
      get :print
    end

    collection do
      get :incoming
      get :pending
      get :search
      get :pending_acknowledgement
      get :ready_to_file
      get :filed
    end
  end

  resources :log_reports do
    member do
      patch :submit
      patch :review
      get :print
    end

    resources :log_entries, only: [:new, :create, :edit, :update, :destroy] do
      member do
        post :create_incident
      end
    end
  end

  resources :incidents do
    member do
      patch :review
      patch :escalate
      patch :resolve
      patch :close
      get :print
    end

    collection do
      get :open_items
      get :escalated
    end
  end

  resources :minutes, only: [:index, :show, :new, :create] do
    member do
      post :process_minutes
    end
  end

  namespace :reports do
    resources :dispatches, only: [:index]

    resources :log_reports, only: [:index] do
      collection do
        get :export_csv
        get :export_pdf
      end
    end

    resources :incidents, only: [:index] do
      collection do
        get :export_csv
        get :export_pdf
      end
    end

    get "summaries/daily", to: "summaries#daily", as: :daily_summary
    get "summaries/monthly", to: "summaries#monthly", as: :monthly_summary
  end
end