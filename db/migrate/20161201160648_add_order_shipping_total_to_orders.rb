class AddOrderShippingTotalToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_total, :decimal, :precision => 10, :scale => 2, :default => 0.00
  end
end
