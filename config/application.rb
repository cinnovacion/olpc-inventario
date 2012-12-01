require File.expand_path('../boot', __FILE__)

require 'rails/all'

# In inventario we do not use the bundler/Gemfile system as we target Fedora
# systems only, expecting that inventario and its dependencies were installed
# through yum.
#
# Under the default Rails "Bundler" system, a Gemfile is used to specify the
# dependencies of the application. On first run, a Gemfile.lock file is created
# which "locks" the application onto a set of specific versions of a gem. For
# example, it may lock the application to rake-1.9.2.
#
# Later on, when rake is updated to v1.9.2.2 by yum, inventario will stop
# working as it can no longer find rake-1.9.2. This is not what we want.
#
# The most appropriate solution to this problem appears to be avoiding use
# of Bundler, hence not having any Gemfile or any Gemfile.lock nonsense.
# Instead, just require the dependencies we need, without any strict
# version checking. Assume that yum/RPM did the work to put the right packages
# in place.
#
# The dependencies must be required at this point so that Railtie initializers
# take effect. Loading them later (e.g. in config/initializers) is too late.
#
# For more background, see
# http://lists.fedoraproject.org/pipermail/ruby-sig/2011-August/000597.html

# Required gems that are expected to be installed through RPMS
require 'active_record' # load early
require 'mysql2'
require 'json'
require 'locale'
require 'gbarcode'
require 'gruff'
require 'spreadsheet'
require 'will_paginate'
require 'gettext_i18n_rails'
require 'foreigner'
require 'audited-activerecord'

# gettext only required for development (for generating po/mo etc).
if Rails.env.development?
  require 'gettext'
end


module InventarioNicaragua
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
