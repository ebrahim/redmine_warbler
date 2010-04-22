module RedmineWarbler # :nodoc:
  class << self
    attr_accessor :environment
    attr_accessor :property_name
    attr_accessor :storage_path
  end
  self.property_name = 'redmine.configuration.storage_path'
  self.environment   = 'production'

  def self.init
    if $servlet_context
      RedmineWarbler.init_runtime
    else
      RedmineWarbler.init_configuration(Rails.configuration)
    end
  end

  def self.init_runtime
    unless defined? JRUBY_VERSION
      Rails.logger.info("\nThe RedmineWarbler Plugin is only useful in JRuby")
      return
    end

    storage_path = java.lang.System.getProperty(property_name)
    if storage_path.blank? 
      Rails.logger.info("\nUse the System Property '#{property_name}' to set a storage path outside of the war file.")
      return
    end

    properties = [[:directory, 'a directory'], [:readable, 'readable'], [:writable, 'writeable']]
    properties.each do |property, description|
      unless File.send("#{property}?", storage_path)
        Rails.logger.error("\nThe configured storage path is not #{description}. Please check your setting of '#{property_name}'.")
        return
      end
    end

    storage_path = storage_path.sub(/\/$/, '')

    self.storage_path = storage_path
    Rails.logger.info("\nStorage path is set to #{self.storage_path.inspect}.")
  end

  def self.init_configuration(config)
    return if config.gems.any? { |gem| gem.name =~ /jruby/ }

    adapter_name = adapter_name(config)

    unless %w[mysql postgresql].include? adapter_name
      Rails.logger.warn("\nThe chosen database adapter might not be supported [mysql postgresql].\n" + 
                        "Please check your #{environment} settings in 'config/database.yml'.")
    end

    warbler_gems = %w[jruby-openssl activerecord-jdbc-adapter activerecord-jdbc%s-adapter jdbc-%s]
    warbler_gems.each do |gem_name|
      config.gem gem_name % adapter_name, :lib => false
    end
  end


  def self.adapter_name(config)
    config.database_configuration[environment]['adapter'].downcase.sub(/jdbc/, '')
  end

  def self.jndi_identifier(config)
    config.database_configuration[environment]['jndi']
  end
end
