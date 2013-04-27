# encoding: utf-8
#
# This file is part of the boar gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Boar
  class PagesController < ApplicationController
    def main
      Boar::Services::Pages.new(self).run(:main)
    end
  end
end
