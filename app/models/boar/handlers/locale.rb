# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    class Locale < Boar::Handlers::Generic
      attr_reader :locale_param

      def initialize(service, options)
        super(service)

        # Get the parameter
        @locale_param = self.get_option(options, :locale_param, @configuration.locale_param)
      end

      def call(*_)
        # Retrieve locale from the controller's params.
        @service.controller.params[@locale_param].ensure_string
      end
    end
  end
end
