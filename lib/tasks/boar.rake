# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# TODO: Rename param here and everywhere else as credentials where appropriate. Could you move them to a class?

namespace :boar do
  def setup(args)
    # Get parameters
    provider_name = args[:provider].ensure_string
    host = args[:host].present? ? args[:host].to_s : "localhost"
    configuration_path = Mustache.render(args[:file].blank? ? Rails.application.config.boar.credentials_file : args[:file], {root: Rails.root})
    all_configurations = nil
    configuration = nil
    provider = nil

    # Find the service
    begin
      provider = Lazier.find_class(provider_name, "Boar::Providers::%CLASS%", true).new
    rescue
      valids = Boar::Providers.constants.collect {|c| c != :Base && Boar::Providers.const_get(c).is_a?(Class) ? c.to_s : nil }.compact
      raise RuntimeError.new((provider_name.present? ? "Invalid provider #{provider_name}." : "No provider specified.") + " Valid providers are: #{valids.join(", ")}.")
    end

    # Open the configuration for the provider
    begin
      all_configurations = YAML.load_file(configuration_path)

      # Get host specific configuration
      configuration = HashWithIndifferentAccess.new(all_configurations[host][provider_name])
      raise ArgumentError if !configuration.is_a?(Hash)
    rescue
      raise RuntimeError.new("Configuration for service #{provider_name.classify} on host #{host} not valid or not found.")
    end

    {path: configuration_path, all: all_configurations, single: configuration, host: host, provider: provider, name: provider_name}
  end

  desc "Updates credentials for a service"
  task :update_credentials, [:provider, :host, :file] => :environment do |_, args|
    params = setup(args)

    configuration = params[:single]
    provider = params[:provider]
    provider_name = params[:name]
    credentials = nil

    # Authorize provider
    begin
      authorizer = Clavem::Authorizer.new(configuration.fetch(:authorizer_host, "localhost"), configuration.fetch(:authorizer_port, "2501")) do |auth, req, res|
        credentials = provider.get_credentials(auth, req, res)
      end

      # Get the redirection URL
      url = provider.redirect_for_authentication(authorizer, configuration)

      # Redirect and fetch new credentials to merge to the old configuration
      authorizer.authorize(url)
    rescue => e
      raise e
      raise case e.class.to_s
        when "ArgumentError" then e
        when "AuthorizationDenied" then Clavem::Exceptions::AuthorizationDenied.new("Authorization denied for provider #{provider_name.classify}.")
        else RuntimeError.new("Authorization failed for provider #{provider_name.classify}.")
      end
    end

    # Update the file
    begin
      params[:provider].update_credentials(credentials, params)
    rescue
      raise RuntimeError.new("Cannot update configuration file #{params[:path]}.")
    end
  end

  desc "Search required information for sharing a file"
  task :search_file, [:path, :provider, :file] => :environment do |_, args|
    params = setup(args)
    path = args[:path]
    name = params[:name]
    info = nil

    raise "Please specify a path." if path.blank?
    begin
      info = params[:provider].search_file(path, params)
    rescue => e
      raise e
      raise RuntimeError.new("Cannot find file #{path} on #{params[:name]}.")
    end

    if info.nil? then
      puts "File #{path} on #{name.classify} doesn't exists."
    elsif !info then
      puts "To share on provider #{name.classify} use the path itself."
    else
      puts "The required information to share #{path} via #{name.classify} are:\n"
      puts "  " + info.to_yaml.gsub(/^---/, "").gsub("\n", "\n  ")
    end
  end
end