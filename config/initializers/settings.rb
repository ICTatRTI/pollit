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

ConfigFilePath = "#{::Rails.root.to_s}/config/settings.yml"
raise Exception, "#{ConfigFilePath} configuration file is missing" unless FileTest.exists?(ConfigFilePath)

YAML.load_file(ConfigFilePath)[::Rails.env].each do |k,v|
  Pollit::Application.config.send("#{k}=", v)
end

