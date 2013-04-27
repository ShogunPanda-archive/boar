# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    class Generic
      include Boar::Utils::Basic

      attr_accessor :service
      attr_accessor :configuration

      def initialize(service, _ = nil)
        @service = service
        @configuration = Rails.application.config.boar
      end

      def call(*_)
        raise Boar::Exceptions::UnImplemented.new
      end
    end
  end
end
