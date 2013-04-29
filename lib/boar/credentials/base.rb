# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Credentials
    class Base
      def redirect_for(_, _)
        raise Boar::Exceptions::UnImplemented
      end

      def get_credentials(_, _, _)
        raise Boar::Exceptions::UnImplemented
      end
    end
  end
end