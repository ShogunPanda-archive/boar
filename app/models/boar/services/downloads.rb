# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Services
    class Downloads < Boar::Services::Generic
      attr_accessor :downloads_configuration

      def downloads
        @skip_cache = @controller.request.params["skip_cache"].to_boolean

        # Get the full path
        path = [@params[:path], @params[:format]].compact.join(".")

        # Handle ACL for the path
        self.handle_authentication(path, @options)

        if !controller.performed? then
          load_configuration(@skip_cache) # Instantiate the configuration

          # Try to match the path against the list of files
          match_data = nil
          found = @downloads_configuration[:files].find{ |k, _| match_data = Regexp.new("^#{k}$").match(path) }
          raise Boar::Exceptions::NotFound.new(path) if !found

          # Get entry
          regexp, entry = split_entry(found)

          # Now execute the provider. This will take care of acting on the controller
          begin
            provider_for_entry(entry).call(path, entry, regexp, match_data, @skip_cache)
          rescue ::Mbrao::Exceptions::Unimplemented => e
            raise Mbrao::Exceptions::Unimplemented.new(e)
          end
        end
      end

      def update
        args = {nothing: true, status: :ok}

        begin
          load_configuration(true)
        rescue => e
          args = {text: e.message, status: 500}
        end

        @controller.render(args)
      end

      def download_file(*args)
        @controller.send_file(*args)
      end

      private
        def split_entry(found)
          rv = found.last
          rv = HashWithIndifferentAccess.new(rv.is_a?(Hash) ? rv : {provider: rv.ensure_string.to_sym}) # Make sure there is a provider key

          # Get default provider is nothing is there
          rv[:provider] ||= get_option(@options, :default_provider, @configuration.default_provider).to_s

          [found.first, rv]
        end

        def provider_for_entry(entry)
          # Instantiate the provider
          @providers ||= {}
          @providers[entry[:provider]] ||= ::Lazier.find_class(entry[:provider], "::Boar::Handlers::Downloads::%CLASS%", true).new(self, @downloads_configuration[:options])
        end

        def load_configuration(force = false)
          # Setup stuff
          config = Rails.application.config.boar
          template = get_option(@options, :config, @configuration.config_file)
          key = @configuration.backend_key("downloads", self, @controller.request)

          # Delete from configuration
          config.backend.del(key) if force

          # Read the key
          raw_downloads = config.backend.get(key)
          raw_downloads = (ActiveSupport::JSON.decode(raw_downloads) rescue nil) if raw_downloads

          @downloads_configuration = if raw_downloads then
            HashWithIndifferentAccess.new(raw_downloads) # Just parse the read data
          else
            # Read the config file
            downloads = YAML.load_file(self.interpolate(template, {root: Rails.root, request: @controller.request, controller: self}))

            # Normalize
            downloads = normalize_configuration(downloads)

            # Save
            config.backend.set(key, downloads.to_json)

            downloads
          end
        end

        def normalize_configuration(configuration)
          configuration = ensure_hash(configuration)

          # Scope by host
          configuration = ensure_hash(configuration[self.handler_for(:hosts).call(@controller.request)])

          # Adjust some defaults
          configuration[:files] = ensure_hash(configuration[:files])
          configuration[:options] = ensure_hash(configuration[:options])

          configuration
        end
    end
  end
end