Rails.application.routes.draw do
  get "duty_sessions/new"
  get "duty_sessions/create"
  get "duty_sessions/end_current"
  get "duty_rosters/index"
  get "duty_rosters/new"
  get "duty_rosters/create"
  get "duty_rosters/edit"
  get "duty_rosters/update"
  get "duty_rosters/destroy"
  get "operation_staffs/index"
  get "operation_staffs/show"
  get "operation_staffs/new"
  get "operation_staffs/create"
  get "operation_staffs/edit"
  get "operation_staffs/update"
  get "operation_staffs/destroy"
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
resources :operation_staffs
  resources :records
  get "daily_filing_log", to: "records#daily_log"

resources :duty_sessions, only: [:new, :create] do
  collection do
    patch :end_current
  end
end
resources :duty_rosters do
  collection do
    post :generate_admin_week
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

    resources :monthly_reports do
      member do
        patch :submit
        patch :review
        patch :archive
      end
    end

    get "summaries/daily", to: "summaries#daily", as: :daily_summary
    get "summaries/monthly", to: "summaries#monthly", as: :monthly_summary
  end
end