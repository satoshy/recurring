class PurchaseOrderLineItemReceipt < ActiveRecord::Base
  
  belongs_to :purchase_order_line_item
  has_many :inventory_transactions, :as => :inv_transaction
  
  after_commit :create_inventory_transactions
  
  def create_inventory_transactions
    if InventoryTransaction.find_by(:inv_transaction_id => id, :inv_transaction_type => "PurchaseOrderLineItemReceipt")
      i = InventoryTransaction.find_by(:inv_transaction_id => id, :inv_transaction_type => "PurchaseOrderLineItemReceipt")
    else
      i = InventoryTransaction.new
    end
    i.update_attributes(:inv_transaction_id => id, :inv_transaction_type => "PurchaseOrderLineItemReceipt", :item_id => purchase_order_line_item.item_id, :quantity => quantity_received)
  end
  
end