desc 'Create the project .war file'
task :war => 'war:default'

namespace :war do
  task :default => [:create_war_tasks, :_warbler]

  desc 'Remove the .war file'
  task :clean   => [:create_war_tasks, '_warbler:clean']

  desc 'Dump diagnostic information'
  task :debug   => [:create_war_tasks, '_warbler:debug']


  task :create_war_tasks do
    begin
      require 'warbler'

    rescue LoadError
      task :_warbler => '_warbler:missing'
      namespace :_warbler do
        task :debug => :missing
        task :clean => :missing

        task :missing do
          puts "'warbler' missing. Fix with '[sudo] gem install warbler' and try again."
          exit 1
        end
      end

    else
      Warbler::Task.new("_warbler", Warbler::Config.new do |config|

        RedmineWarbler.init_working_copy

        # configure jndi sources in web.xml
        jndi = RedmineWarbler::Jdbc.jndi_identifier(Rails.configuration)

        config.webxml.jndi = jndi unless jndi.blank?

        # add .specification for rubytree to avoid warning in servlet start up
        rubytree_spec = 'vendor/gems/rubytree-0.5.2/.specification'
        config.includes << rubytree_spec if File.exist?(rubytree_spec)
      end)
    end
  end
end
