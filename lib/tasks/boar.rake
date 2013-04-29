# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

namespace :boar do
  desc "Updates credentials for a service"
  task :update_credentials, [:provider, :file] => :environment do |_, args|
    # Get parameters
    provider_name = args[:provider].try(:to_sym)
    configuration_path = Mustache.render(args[:file].blank? ? Rails.application.config.boar.credentials_file : args[:file], {root: Rails.root})

    # Setup variables
    configuration = nil
    provider = nil

    # Find the service
    begin
      raise ArgumentError.new if provider_name.blank?
      provider = Lazier.find_class(provider_name, "Boar::Credentials::%CLASS%", true).new
    rescue
      valids = Boar::Credentials.constants.collect {|c| c != :Base && Boar::Credentials.const_get(c).is_a?(Class) ? c.to_s.parameterize : nil }.compact
      raise ArgumentError.new((provider_name.present? ? "Invalid provider #{provider_name}." : "No provider specified.") + " Valid providers are: #{valids.join(", ")}.")
    end

    # Open the configuration for the provider
    begin
      configuration = YAML.load_file(configuration_path).deep_symbolize_keys
      raise ArgumentError.new("Configuration for service #{provider_name} not found.") if configuration[provider_name].blank?
    rescue => e
      raise e.is_a?(ArgumentError) ? e : RuntimeError.new("Cannot read file #{configuration_path}.")
    end

    # Authorize provider
    begin
      credentials = nil

      authorizer = Clavem::Authorizer.new do |auth, req, res|
        credentials = provider.get_credentials(auth, req, res)
      end

      # Get the redirection URL
      url = provider.redirect_for(authorizer, configuration[provider_name])

      # Redirect and fetch new credentials to merge to the old configuration
      authorizer.authorize(url)
      configuration[provider_name].merge!(credentials)
    rescue => e
      raise case e.class.to_s
        when "ArgumentError" then e
        when "AuthorizationDenied" then Clavem::Exceptions::AuthorizationDenied.new("Authorization denied for provider #{provider_name}.")
        else RuntimeError.new("Authorization failed for provider #{provider_name}.")
      end
    end

    # Update the file
    begin
      open(configuration_path, "w") {|f| f.write(configuration.to_yaml) }
    rescue => e
      raise e.is_a?(ArgumentError) ? e : RuntimeError.new("Cannot write file #{configuration_path}.")
    end
  end
end