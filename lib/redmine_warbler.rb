module RedmineWarbler # :nodoc:
  class StoragePath
    class << self
      attr_accessor :property_name

      def find
        storage_path = via_property || via_context_parameter

        if storage_path.blank?
          Rails.logger.info("\nUse the System Property '#{property_name}' " +
                            "or a Context Parameter of the same name " +
                            "to set a storage path outside of the war file.")
          return
        end

        properties = [[:directory, 'a directory'], [:readable, 'readable'], [:writable, 'writeable']]
        properties.each do |property, description|
          unless File.send("#{property}?", storage_path)
            Rails.logger.error("\nThe configured storage path is not #{description}. Please check your setting of '#{property_name}'.")
            return
          end
        end

        storage_path.sub(/\/$/, '')
      end

      def via_property
        java.lang.System.getProperty(property_name)
      end

      def via_context_parameter
        $servlet_context.getInitParameter(property_name)
      end
    end
  end
  StoragePath.property_name = 'redmine.configuration.storage_path'

  class Jdbc
    def self.adapter_name(config)
      config.database_configuration[RedmineWarbler.environment]['adapter'].downcase.sub(/jdbc/, '')
    end

    def self.jndi_identifier(config)
      config.database_configuration[RedmineWarbler.environment]['jndi']
    end
  end

  class << self
    attr_accessor :environment
    attr_accessor :storage_path
  end
  self.environment   = 'production'

  def self.init_in_container
    return unless $servlet_context

    storage_path = StoragePath.find
    Attachment.storage_path = storage_path unless storage_path.blank?
    Rails.logger.info("\nStorage path is set to #{Attachment.storage_path.inspect}.")
  end

  def self.init_gem_configuration(config)
    return if config.gems.any? { |gem| gem.name =~ /jruby/ }

    warbler_gems = %w[jruby-openssl activerecord-jdbc-adapter]

    case Jdbc.adapter_name(config)
    when 'mysql'
      warbler_gems += %w[activerecord-jdbcmysql-adapter jdbc-mysql]
    when 'postgresql'
      warbler_gems += %w[activerecord-jdbcpostgresql-adapter jdbc-postgres]
    else
      Rails.logger.warn(
          "\nThe chosen database adapter might not be supported " +
          "[mysql postgresql].\n" +
          "Please check your #{environment} settings in 'config/database.yml'.")
    end

    warbler_gems.each do |gem_name|
      config.gem gem_name, :lib => false
    end
  end
end
