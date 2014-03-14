SUMMARY
====================

This extension provides a Shipping Calculator for use with Australia Post's eParcel Service.

Currently only tested against Spree 2-1 stable branch.

INSTALLATION
============

1. This gem requires xml parsing and several support gems. Use bundler to install. Add the following to your Gemfile

	`gem 'spree_aus_post_shipping', github: 'mrmikemon/spree_aus_post_shipping'`

2. Run bundler

	`bundle install`

CONFIGURATION
=============

In your Spree Initialiser add the following lines
```ruby
Spree::AusPostShipping::Config = Spree::AusPostShippingConfiguration.new
Spree::AusPostShipping::Config[ :origin_postcode ] =  -- post code your shipping from --

Spree::AusPostShipping::Config[ :default_width ] = -- default width for an order (cms) --

Spree::AusPostShipping::Config[ :default_height ] = -- default height for an order (cms) --

Spree::AusPostShipping::Config[ :default_length ] = -- default length for an order (cms) --

Spree::AusPostShipping::Config[ :default_weight ] = -- default weight for an order (cms) --

Spree::AusPostShipping::Config[ :api_key ] = -- obtain your API key from australia post ---

Spree::AusPostShipping::Config[ :service_types ] = ['aus_parcel_regular']	# change for other shipping types
```

The Calculator will sum up any dimensions or weight information from order line items. If these aren't available
then the shipping fees will be calculated with the default settings. The origin_postcode needs to the set to
calculate the correct delivery fees. The service_type will select the type of shipping.


SEED DATA
=============
```ruby
  begin
    australia = Spree::Zone.find_by_name!("Australia")
    puts "found it"
  rescue ActiveRecord::RecordNotFound
    puts "Couldn't find 'Australia' zone."
    exit
  end

  shipping_category = Spree::ShippingCategory.find_or_create_by_name!('Default')

  shipping_methods = [
    {
      :name => "Australia Post eParcel",
      :zones => [australia],
      :calculator => Spree::Calculator::Shipping::AusPostShipping.create!,
      :shipping_categories => [shipping_category]
    },
  ]

  shipping_methods.each do |shipping_method_attrs|
    ship_method = Spree::ShippingMethod.create!(shipping_method_attrs )
    ship_method.save!
  end
  ```


Hope you enjoy. Contributions welcome.

Mike Monaghan, released under the New BSD License.
