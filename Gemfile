source :rubygems

gem "rails", "5.2.5", :require => false
gem "will_paginate", "~> 3.0.5"
gem "acts-as-taggable-on", "~> 2.0.0" 
gem "RedCloth", ">= 4.3.0", :require => "redcloth"
gem 'i18n', '~> 0.8.0'

database = begin
  File.read(File.dirname(__FILE__) + '/config/database.yml').scan(/production.+?adapter\W+(\w+)/im).join
rescue
  nil
end

case database
when /postgres/, /pg/
  gem 'pg', :require => false
when /sqlite/
  gem 'sqlite3-ruby', :require => false
else
  gem 'mysql', :require => false
end

group :test do
  gem "rspec", "~> 1.3.0", :require => "spec"
  gem "rspec-rails", "~> 1.3.2", :require => "spec"
  gem "shoulda"
end
