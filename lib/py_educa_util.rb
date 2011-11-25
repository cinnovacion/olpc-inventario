#     Copyright Paraguay Educa 2009
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
# 
#                                                                          

# # #
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #

module PyEducaUtil

  def self.getAppRevisionNum()
    self.getSvnKey("Revision", true).to_i
  end

  def self.getSvnKey(key_name, strip_spaces = false)
    svn_output = PyEducaUtil::getSvnOutput()

    svn_value = ""
    svn_output.each { |l|
      if l.match(/^#{key_name}/) 
        l.chomp!
        k, svn_value = l.split(/:/)
        break
      end
    }

    svn_value.gsub!(/ /, "") if strip_spaces
    
    svn_value
  end


  def self.getSvnOutput()

    Dir::chdir Rails.root
    cmd = "svn info"
    svn_output = []
    begin

      IO.popen(cmd, "r") do |fp|
        svn_output = fp.readlines
      end
    rescue

      Rails.logger.error("\n WARNING: SVN not available \n")
    end
    svn_output
  end


end
