# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    class Authentication < Boar::Handlers::Generic
      def call(*args)
        # Get path
        path = args[0]

        if self.required_for?(path) then
          self.authenticating_for?(path) ? self.authenticate_for(path) : self.request_authentication_for(path)
        end
      end

      def required_for?(_ = nil)
        false # By default we don't require authentication
      end

      def authenticating_for?(_ = nil)
        false # By default we're not authentication
      end

      def request_authentication_for(_ = nil)
        # Render the view for authentication
        @service.controller.render(@service.handler_for(:views).call(:authentication))
      end

      def authenticate_for(_ = nil)
        # By default we are authenticating
        true
      end
    end
  end
end
