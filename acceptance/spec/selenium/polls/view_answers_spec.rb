# Copyright (C) 2011-2012, InSTEDD
# 
# This file is part of Pollit.
# 
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../../spec_helper', __FILE__)

acceptance_test do
  get "/"
  login_as "mmuller+4691@manas.com.ar", "123456789"
  go_to_my_polls
  2.upto 6 do |n|
    answers = @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[#{n}]//span").text.to_i
    if answers != 0
        sleep 5
        @driver.find_element(:xpath, "//table[contains(@class, 'GralTable TwoColumn CleanTable ItemsTable')]/tbody/tr[#{n}]").click
        @driver.find_element(:link, "Answers").click
        i_should_see "Respondent"
      break
    end
  end
  
end
