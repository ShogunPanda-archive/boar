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

        def call(_, _, _, _)
          raise Boar::Exceptions::UnImplemented.new
        end

        def class_key
          self.class.name.demodulize.parameterize.to_sym
        end

        def credentials
          # TODO: Translate domain+port using host mapper in the interpolation - Also, only load the specific section
          all_credentials = YAML.load_file(self.interpolate(@configuration.credentials_file, {root: Rails.root, request: @service.controller.request, controller: @service.controller}))
          all_credentials.fetch(self.class_key)
        end
      end
    end
  end
end
