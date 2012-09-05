source 'https://rubygems.org'

gem 'rails', '3.2.0'
gem 'compass'
gem 'haml'
gem 'haml-rails'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg', :group => [:development, :production]
gem 'devise'
gem 'activeadmin', '=0.4.0' 
gem 'aasm'
gem "paperclip", "~> 2.3"
gem 'aws-s3'
gem 'acts-as-taggable-on'
gem 'rails3-jquery-autocomplete', :git => "git://github.com/crowdint/rails3-jquery-autocomplete.git"
gem 'aws-sdk'
gem 'braintree'
gem 'permalink_fu'
gem 'bartt-ssl_requirement', '~>1.4.0', :require => 'ssl_requirement'
gem 'uuid'
gem 'carmen', :git => 'git://github.com/jim/carmen.git'
gem 'kaminari'
gem 'bootstrap_kaminari', :git => 'git://github.com/dleavitt/bootstrap_kaminari.git'
gem "formtastic", "~> 2.1.1"
gem 'tabs_on_rails'
gem 'state_machine'
gem "hominid"
gem 'nokogiri'
gem 'exception_notification', :require => 'exception_notifier'
gem "rails_best_practices"
gem "twilio-ruby"
gem "awesome_print"
gem 'rack-ssl-enforcer'




# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end
  
gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

group :test, :development do
  gem 'rspec-rails'
  gem "factory_girl_rails", ">= 1.7.0"
  #gem 'ruby-debug19', :require => 'ruby-debug'
end
 
group :test do
  gem 'sqlite3'
  gem "simplecov", "~> 0.6.1"


  gem 'webrat'
  gem 'selenium-client'
  
  gem 'launchy'
  gem "email_spec", ">= 1.2.1"
  #gem 'capybara-webkit'
  #gem "capybara", ">= 1.1.2"
  gem "cucumber-rails", ">= 1.3.0"
  gem "database_cleaner", ">= 0.7.1"
  gem 'shoulda-matchers'
  gem 'spork', '~> 0.9.0.rc'
  gem 'guard-spork'
end
