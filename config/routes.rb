Rails.application.routes.draw do
  
  authenticate :user do
    scope "/admin" do
      resource :home, :controller => :home do 
        member do
          get :authenticate
          get :oauth_callback
        end
      end
      resources :accounts do
        member do
          get :statements
          get :statements_all
        end
        resources :contacts
        resources :charges
        resources :credit_cards
        resources :equipment do
          resources :meters, :shallow => true do
            resources :meter_readings, :shallow => true
          end
        end
        resources :invoices, :shallow => true do
          # resources :payments, :shallow => true
        end
        resources :payment_plan_templates do
          resources :payment_plans
        end
        resources :payment_plans do
          resources :invoices
        end
      end
      resources :account_item_prices
      resources :account_item_price_imports
      resources :assets
      resources :brands
      resources :brand_imports
      resources :categories
      resources :charges
      resources :contacts
      resources :credit_cards
      resources :customers
      resources :equipment
      resources :equipment_imports
      resources :equipment_alerts
      resources :groups do 
        member do 
          get :equipment_by_customer
          get :invoices_by_customer
          get :items
          get :items_by_customer
          get :items_for_customer
          get :statements
        end
      end
      resources :group_item_prices
      resources :inventories
      resources :invoices
      resources :items do
        collection do
          get :search
          get :actual_price_by_item_number_and_account_id
        end
      end
      resources :item_categories
      resources :item_imports
      resources :item_vendor_prices
      resources :item_vendor_price_imports
      resources :jobs
      resources :makes
      resources :machine_models
      resources :machine_model_items
      resources :meters
      resources :meter_readings
      resources :orders do
        collection do
          get :incomplete
          get :locked
          get :shipped
          get :fulfilled
          get :unfulfilled
          get :canceled
          get :unpaid
          get :returnable_items
        end
        member do
          put :lock
          put :resend_invoice
          post :resend_invoice_notification
          put :resend_order
          post :resend_order_confirmation
          put :credit_hold
        end
        resources :shipments, :only => [:new, :create]
        # resources :payments, :shallow => true
        resources :invoices
      end
      resources :order_line_items
      resources :payments
      resources :payment_plans
      resources :payment_plan_templates
      resources :purchase_orders do
        member do
          get :line_items_from_order
          put :lock
          put :resend_invoice
          put :resend_order
        end
        resources :purchase_order_receipts, :only => [:new, :create]
      end
      resources :purchase_order_line_items
      resource :reports, :only => :index do
        get :sales_tax
        get :item_usage
        get :ar_aging
      end
      resources :return_authorizations
      resources :roles do
        collection do
          post :add_role_to_user
          delete :remove_role_from_user
        end
      end
      resources :sales_reps
      resources :settings
      resources :tax_rates
      resources :users do
        get :edit_password
        get :reset_password
      end
      resources :vendors
      get "items/delete/:id" => "items#delete"
      get "/" => "home#show"
      get "/check_for_import" => "item_imports#check_for_import"
    end
  end
  
  devise_for :users, :controllers => { 
        sessions: "users/sessions",
        passwords: "users/passwords",
        registrations: "users/registrations"
  }
  
  get   "checkout/address" => "checkout#address"
  patch "checkout/address" => "checkout#update_address"
  get   "checkout/shipping" => "checkout#shipping"
  patch "checkout/shipping" => "checkout#update_shipping"
  get   "checkout/payment" => "checkout#payment"
  patch "checkout/payment" => "checkout#update_payment"
  get   "checkout/confirm" => "checkout#confirm"
  patch "checkout/complete"=> "checkout#complete"
  
  post  "/add_to_cart" => "shop#add_to_cart"
  patch "/add_to_cart" => "shop#add_to_cart"
  post  "/update_cart" => "shop#update_cart"
  patch "/update_cart" => "shop#update_cart"
  
  get "/my_account/items" => "shop#my_items"
  get "/my_account/order/:order_number" => "shop#view_order"
  get "/my_account/invoice/:invoice_number/pay" => "shop#pay_invoice"
  get "/my_account/invoice/:invoice_number" => "shop#view_invoice"
  get "/my_account/:account_id" => "shop#view_account"
  get "/my_account" => "shop#my_account"
  get "/edit_account" => "shop#edit_account"
  
  get "/cart" => "shop#cart"
  get "/search" => "shop#search"
  get "/search_autocomplete" => "shop#search_autocomplete"
  
  get "/categories/:parent_id" => "shop#categories"
  get "/:category/:item" => "shop#item"
  get "/:category" => "shop#category"
  get "/" => "shop#index"
  
  namespace :api, defaults: {format: :json} do
    scope :v1 do
      resources :equipment_alerts, only: [:index, :show, :create, :update]
    end
  end

end