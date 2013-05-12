# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Providers
    class Base
      def redirect_for_authentication(_, _)
        raise Boar::Exceptions::UnImplemented
      end

      def get_credentials(_, _, _)
        raise Boar::Exceptions::UnImplemented
      end

      def update_credentials(credentials, params)
        params[:all][params[:host]][params[:name]] = params[:single].merge(credentials).to_hash
        open(params[:path], "w") {|f| f.write(params[:all].to_yaml) }
      end

      def search_file(_, _)
        false
      end
    end
  end
end