# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    module Downloads
      class Base < Boar::Handlers::Generic
        attr_reader :options, :provider_options

        def initialize(service, options)
          super(service)

          @options = ensure_hash(options)

          # Get the configuration for the provider
          @provider_options = ensure_hash(@options[:providers]).fetch(self.class_key, {}).deep_symbolize_keys
        end

        # TODO: Create something Elephas.use for the remote implementations
        def call(_, _, _, _)
          raise Boar::Exceptions::UnImplemented.new
        end

        def class_key
          self.class.name.demodulize.underscore
        end

        def load_credentials
          self.credentials_params[:single]
        end

        def credentials_params
          host = @service.handler_for(:hosts).call(@service.controller.request)
          path = self.interpolate(@configuration.credentials_file, {root: Rails.root, request: @service.controller.request, controller: @service.controller})
          all = YAML.load_file(path)
          name = self.class_key

          {single: HashWithIndifferentAccess.new(all.fetch(host).fetch(name)), path: path, all: all, host: host, provider: self, name: name }
        end

        def update_credentials(credentials, params = nil)
          params ||= self.credentials_params
          params[:all][params[:host]][params[:name]] = params[:single].merge(credentials).to_hash
          open(params[:path], "w") {|f| f.write(params[:all].to_yaml) }
        end

        def finalize_path(path, match_data)
          path.gsub(/\\(\d+)/) { |m| match_data[$1.to_i] }
        end
      end
    end
  end
end
