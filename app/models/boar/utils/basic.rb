# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Utils
    module Basic
      def ensure_hash(obj, default = {})
        HashWithIndifferentAccess.new(obj.is_a?(Hash) ? obj : default)
      end

      def get_option(options, key, default = nil)
        begin
          options.symbolize_keys.fetch(key.to_sym)
        rescue Exception => _
          block_given? ? yield(key) : default
        end
      end

      def interpolate(template, args)
        Mustache.render(template, args)
      end
    end
  end
end