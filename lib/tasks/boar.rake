# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

namespace :boar do
  desc "Updates credentials for a service"
  task :update_credentials, [:provider, :host, :file] => :environment do |_, args|
    # Get parameters
    provider_name = args[:provider].ensure_string
    host = args[:host].present? ? args[:host].to_s : "localhost"
    configuration_path = Mustache.render(args[:file].blank? ? Rails.application.config.boar.credentials_file : args[:file], {root: Rails.root})

    # Setup variables
    all_configurations = nil
    configuration = nil
    provider = nil

    # Find the service
    begin
      provider = Lazier.find_class(provider_name, "Boar::Credentials::%CLASS%", true).new
    rescue
      valids = Boar::Credentials.constants.collect {|c| c != :Base && Boar::Credentials.const_get(c).is_a?(Class) ? c.to_s.parameterize : nil }.compact
      raise RuntimeError.new((provider_name.present? ? "Invalid provider #{provider_name}." : "No provider specified.") + " Valid providers are: #{valids.join(", ")}.")
    end

    # Open the configuration for the provider
    begin
      all_configurations = YAML.load_file(configuration_path)

      # Get host specific configuration
      configuration = HashWithIndifferentAccess.new(all_configurations[host][provider_name])
      raise ArgumentError if !configuration.is_a?(Hash)
    rescue => e
      raise RuntimeError.new("Configuration for service #{provider_name} on host #{host} not valid or not found.")
    end

    # Authorize provider
    begin
      credentials = nil

      authorizer = Clavem::Authorizer.new(configuration.fetch(:authorizer_host, "localhost"), configuration.fetch(:authorizer_port, "2501")) do |auth, req, res|
        credentials = provider.get_credentials(auth, req, res)
      end

      # Get the redirection URL
      url = provider.redirect_for(authorizer, configuration)

      # Redirect and fetch new credentials to merge to the old configuration
      authorizer.authorize(url)
      all_configurations[host][provider_name] = configuration.merge(credentials).to_hash
    rescue => e
      raise e
      raise case e.class.to_s
        when "ArgumentError" then e
        when "AuthorizationDenied" then Clavem::Exceptions::AuthorizationDenied.new("Authorization denied for provider #{provider_name}.")
        else RuntimeError.new("Authorization failed for provider #{provider_name}.")
      end
    end

    # Update the file
    begin
      open(configuration_path, "w") {|f| f.write(all_configurations.to_yaml) }
    rescue => e
      raise RuntimeError.new("Cannot update configuration file #{configuration_path}.")
    end
  end
end