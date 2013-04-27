# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    class Views < Boar::Handlers::Generic
      attr_reader :views

      def initialize(service, options)
        super(service)

        # Get the views
        @views = self.get_option(options, :views, @configuration.views)
      end

      def call(*args)
        # Interpolate the template
        self.interpolate(@views.fetch(args[0]), ensure_hash(args[1]))
      end
    end
  end
end
