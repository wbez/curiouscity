=begin
Copyright 2013 WBEZ
This file is part of Curious City.

Curious City is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Curious City is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Curious City.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'spec_helper'
require 'database_cleaner'
require 'capybara/rspec'
require 'capybara/rails'
require 'site_prism'

$LOAD_PATH.unshift(Rails.root.join("spec/pages"))
Dir[Rails.root.join("spec/pages/**/*.rb")].each { |f| require f }

# expand Capybara default wait time out to 10 seconds to make Snap happy
Capybara.default_wait_time=30
Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Capybara::DSL
end


def switch_to_popup
  # page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
end

def signin_as_admin
  user = FactoryGirl.create(:user)
  @signin_page = Admin::Signin.new
  @signin_page.load
  @signin_page.username.set(user.username)
  @signin_page.password.set(user.password)
  @signin_page.signin_button.click
end

def signin_as_reporter
  user = FactoryGirl.create(:user, :reporter)
  @signin_page = Admin::Signin.new
  @signin_page.load
  @signin_page.username.set(user.username)
  @signin_page.password.set(user.password)
  @signin_page.signin_button.click
end
