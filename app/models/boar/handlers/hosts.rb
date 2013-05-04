# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  module Handlers
    class Hosts < Boar::Handlers::Generic
      def initialize(*args)
      end

      def call(request, domain = nil, port = nil)
        domain ||= request.domain
        port ||= request.port
        rv = [domain, port].join(":")

        if rv == "localhost:3000" then
          rv = "localhost"
        elsif ["http/80", "https/443"].include?([request.protocol, request.port].join("/")) then
          rv = request.domain
        end

        rv
      end
    end
  end
end