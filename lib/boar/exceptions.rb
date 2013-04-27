# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Exceptions
    class Error < ::Exception
      attr_reader :code

      def initialize(code, message = nil)
        super(message)
        @code = code
      end

      def self.must_raise?(exception)
        exception.is_a?(Lazier::Exceptions::Dump) && Rails.env.development?
      end
    end

    class ServerError < Error
      def initialize(message)
        super(500, message)
      end
    end

    class UnImplemented < Error
      def initialize(message = nil)
        super(501, message)
      end
    end

    class AuthorizationFailed < Error
      def initialize(message = nil)
        super(403, message)
      end
    end

    class NotFound < Error
      def initialize(message = nil)
        super(404, message)
      end
    end
  end
end