require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare do
  Attachment.storage_path = RedmineWarbler.storage_path unless RedmineWarbler.storage_path.blank?
end

Redmine::Plugin.register :redmine_warbling do
  name 'Redmine Warbler plugin'
  author 'Gregor Schmidt • Finn GmbH'
  author_url 'http://github.com/finnlabs/redmine_warbler/'
  description 'This plugin adds functionality to ease the deployment in a Servlet Container.'
  version '0.0.1'
end

RedmineWarbler.init
