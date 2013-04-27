# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    class Root < Boar::Handlers::Generic
      attr_reader :template

      def initialize(service, options)
        super(service)

        # Get the template for building the root
        @template = self.get_option(options, :directory, @configuration.directory)
      end

      def call(*_)
        # Interpolate to a directory
        Pathname.new(self.interpolate(@template, {root: Rails.root, domain: @service.controller.request.domain, controller: @service.controller}))
      end
    end
  end
end
