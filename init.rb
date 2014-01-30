require 'redmine'

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    RedmineWarbler.init_in_container
  end
else
  require 'dispatcher'

  Rails.configuration.after_initialize do
    RedmineWarbler.init_gem_configuration(Rails.configuration)
  end

  Dispatcher.to_prepare do
    RedmineWarbler.init_in_container
  end
end

Redmine::Plugin.register :redmine_warbler do
  name 'Redmine Warbler plugin'
  author 'Gregor Schmidt - Finn GmbH'
  author_url 'http://github.com/finnlabs/redmine_warbler/'
  description 'This plugin adds functionality to ease the deployment in a Servlet Container.'
  version '0.1'
end
