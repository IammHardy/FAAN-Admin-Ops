Rails.application.routes.draw do
  get "incidents/index"
  get "incidents/show"
  get "incidents/new"
  get "incidents/create"
  get "incidents/edit"
  get "incidents/update"
  get "incidents/destroy"
  get "incidents/review"
  get "incidents/escalate"
  get "incidents/resolve"
  get "incidents/close"
  get "incidents/print"
  get "incidents/open_items"
  get "incidents/escalated"
  get "log_entries/create"
  get "log_entries/edit"
  get "log_entries/update"
  get "log_entries/destroy"
  get "log_reports/index"
  get "log_reports/show"
  get "log_reports/new"
  get "log_reports/create"
  get "log_reports/edit"
  get "log_reports/update"
  get "log_reports/destroy"
  get "log_reports/submit_report"
  get "log_reports/review"
  get "log_reports/print"
  get "dispatches/index"
  get "dispatches/show"
  get "dispatches/new"
  get "dispatches/create"
  get "dispatches/edit"
  get "dispatches/update"
  get "dispatches/destroy"
  get "dispatches/pending"
  get "dispatches/search"
  get "dispatches/print"
  get "users/index"
  get "users/show"
  get "users/new"
  get "users/create"
  get "users/edit"
  get "users/update"
  get "users/destroy"
  get "units/index"
  get "units/show"
  get "units/new"
  get "units/create"
  get "units/edit"
  get "units/update"
  get "units/destroy"
  get "departments/index"
  get "departments/show"
  get "departments/new"
  get "departments/create"
  get "departments/edit"
  get "departments/update"
  get "departments/destroy"
  get "dashboard/index"
  devise_for :users

  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  resources :departments
  resources :units
  resources :users
  resources :audit_logs, only: [:index, :show]

  resources :dispatches do
    member do
      patch :mark_dispatched
      patch :mark_received
      patch :mark_acknowledged
      patch :mark_filed
      get :print
    end

    collection do
      get :pending
      get :search
    end
  end

  resources :log_reports do
    member do
      patch :submit_report
      patch :review
      get :print
    end

    resources :log_entries, only: [:create, :edit, :update, :destroy]
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

 
end