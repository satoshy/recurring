require 'sidekiq-scheduler'

class OrderLineItemFromEquipmentAlert
  
  include Sidekiq::Worker
  
  def perform()
    j = Job.new
    puts "********* Crating Orders from Equipment Alerts *********"
    j.job_name = "Crating Orders from Equipment Alerts"
    j.notes = ""
  
    alerts = EquipmentAlert.where(:active => true, :alert_type => "start", :order_line_item_id => nil)
  
    alerts.each do |alert|
      j.notes += "[{alert_id: #{alert.id}}"
    
      if alert.equipment_id
        j.notes += "{equipment_id: #{alert.equipment_id}}"
        equipment = alert.equipment
      
        if equipment.is_managed == true
          j.notes += "{is_manged: true}"
          j.notes += "{customer_id: #{equipment.customer.id unless equipment.nil?}}"
        
          customer = equipment.customer
        
          order = Order.where(:locked => nil, :completed_at => nil, :customer => equipment.account_id).first
        
          if order.nil?
            order = Order.new(:customer => customer)
          end
        
          j.notes += "{order_id: #{order.id}}"
        
          order.notes = "Auto Supply Order"
          order.sales_rep_id = customer.sales_rep_id
          order.ship_to_account_name = customer.name
          order.ship_to_address_1 = customer.ship_to_address_1
          order.ship_to_address_2 = customer.ship_to_address_2
          order.ship_to_city = customer.ship_to_city
          order.ship_to_state = customer.ship_to_state
          order.ship_to_zip = customer.ship_to_zip
          order.email = customer.email
          order.bill_to_account_name = customer.name
          order.bill_to_address_1 = customer.bill_to_address_1
          order.bill_to_address_2 = customer.bill_to_address_2
          order.bill_to_city = customer.bill_to_city
          order.bill_to_state = customer.bill_to_state
          order.bill_to_zip = customer.bill_to_zip
          order.bill_to_email = customer.bill_to_email
        
          supply = equipment.find_supply(alert.supply_type, alert.supply_color)
          j.notes += "{supply: #{supply.item_id unless supply.nil?}}"
        
          unless supply.nil?
            line = order.order_line_items.new
            line.item_id = supply.item_id
            line.quantity = 1
            line.description = "ID# #{equipment.number} / #{equipment.location}"
            line.price = line.item.actual_price(equipment.account_id)
          
            if line.save
              alert.update_attributes(:active => false, :order_line_item_id => line.id)
              j.notes += "{status : sucess}]"
            else
              j.notes += "{status : fail}]"
            end
        
          else
            j.notes += "{is_manged: false}"
          end
      
        end
      end
    end
    puts "********* END *********"
    j.save
  end
  
end