require 'rest-client'

module Spree
  module Calculator::Shipping
    class AusPostShipping < ShippingCalculator

      @shipping_fee
    
      def self.service_name
        "Australia Post Shipping Calculator"
      end
    
      def self.description
        "Australia Post eParcel"
      end
    
      def activate
        Calculator::AusPostShipping.register
      end

      def available?(package)
        if !package.order.ship_address.nil? && !package.order.ship_address.zipcode.nil?
          @shipping_fee = calculate_shipping(package)
          !@shipping_fee.nil?
        else
          false
        end
      end
    
      def compute(package)
        if !package.order.ship_address.nil? && !package.order.ship_address.zipcode.nil?
          if @shipping_fee.nil?
            @shipping_fee = calculate_shipping(package)
           end
           @shipping_fee
       else
         nil
       end
      end

      def calculate_shipping(package)

        weight = Spree::AusPostShipping::Config[ :default_weight ]
        # estimate the total order's cubic weight, simple algorithm here assume a minimum weight
        # unless we find a item that is heavier
        # this is an estimate only based on finding the heaviest item - keep the customers buying
        package.flattened.each do | line_item | 
          if not line_item.variant.weight.nil? 
            if line_item.variant.weight > weight
              weight = line_item.variant.weight
            end
          end
        end
      
        services = retrieve_rates( :origin_postcode => Spree::AusPostShipping::Config[ :origin_postcode ],
                                :dest_postcode => package.order.ship_address.zipcode,
                                :weight => weight )

        allowed_service_types = Spree::AusPostShipping::Config[ :service_types ]

        if services 
          shipment_cost = 0
          # select a service that matches our available service types and has the lowest cost
          services.each do | service | 
            service_name = service[ :name ]
            service_price = service[ :price ]

            if allowed_service_types.include? service_name
              if service_price > shipment_cost
                shipment_cost = service_price
              end
            end
          end
        else 
          shipment_cost = nil
        end
        if shipment_cost == 0
          shipment_cost = nil
        else 
          BigDecimal.new( shipment_cost.to_s ).round(2)
        end
        shipment_cost
      end

      private

      # extract maximum price from price range in shipment service price
      def max_price( price_text )
        # if its a price range, extract the highest price
        if price_text =~ / to /i
          price = price_text.scan(/[0-9\.]+/i)[1]
        else 
          price = price_text.scan(/[0-9\.]+/i).first
        end
        return price.to_f
      end

      def retrieve_rates( settings={} )
        host_name = 'auspost.com.au'
        api_name = '/api/postage/parcel/domestic/service.xml'
        origin_postcode = settings[ :origin_postcode ]
        dest_postcode = settings[ :dest_postcode ]
        weight = settings[ :weight ]
        height = Spree::AusPostShipping::Config[ :default_height ]
        width = Spree::AusPostShipping::Config[ :default_width ]
        length = Spree::AusPostShipping::Config[ :default_length ]
        api_key = Spree::AusPostShipping::Config[ :api_key ]

        services = []      
        auspost_url = "https://#{host_name}#{api_name}?from_postcode=#{origin_postcode}&to_postcode=#{dest_postcode}&length=#{length}&width=#{width}&height=#{height}&weight=#{weight}"
        begin
          result = ::RestClient.get auspost_url, { :auth_key => api_key }
          doc = Nokogiri::XML( result )
          # find services in the response document
          service_nodes = doc.xpath('/services/service')
          puts "Services Found: #{service_nodes.length}"
          service_nodes.each do | service_node |
            service = {}
            service[ :name ] = service_node.xpath('code').text.downcase
            service[ :price ] = max_price service_node.xpath('price').text
            services << service
          end
        rescue Exception
          #raise StandardError.new("Couldn't obtain service charges for AusPost Courier")
          return []
        end
        services
      end
    end
  end
end
