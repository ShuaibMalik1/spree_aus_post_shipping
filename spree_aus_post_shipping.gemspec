# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_aus_post_shipping'
  s.version     = '1.0.4'
  s.summary     = 'A Shipping Calculator for Australia Post Parcels'
  s.description = 'A Shipping Calculator for Australia Post Parcels utilising the AusPost postage calculator API for shipping fee calcualtions'
  s.required_ruby_version = '>= 1.9.2'
  s.add_dependency('spree_core', '>= 1.0.0')

  s.author            = 'Mike Monaghan'
  s.email             = 'mike@ignitedsoftware.com'
  s.homepage          = 'http://ignitedsoftware.com'

  #s.files         = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'nokogiri'
  s.add_dependency 'rest-client'

  # test suite
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.7'
  s.add_development_dependency 'sqlite3'
end
