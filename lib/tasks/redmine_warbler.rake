begin
  require 'warbler'

  Warbler::Task.new("war", Warbler::Config.new do |config|
    # configure jndi sources in web.xml
    jndi = RedmineWarbler::Jdbc.jndi_identifier(Rails.configuration)

    config.webxml.jndi = jndi unless jndi.blank?

    # add .specification for rubytree to avoid warning in servlet start up
    rubytree_spec = 'vendor/gems/rubytree-0.5.2/.specification'
    config.includes << rubytree_spec if File.exist?(rubytree_spec)
  end)

rescue LoadError

  task :war => 'war:missing'
  namespace :war do
    task :debug => :missing
    task :clean => :missing

    task :missing do
      puts "'warbler' missing. Fix with '[sudo] gem install warbler' and try again."
      exit 1
    end
  end
end
