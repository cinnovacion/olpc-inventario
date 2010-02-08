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

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                         
class Notifier < ActionMailer::Base

  def lendings_reminder(email, message)

    # Prepare & send
    from "inventario@paraguayeduca.org"
    recipients email
    subject "Paraguay Educa le recuerda"
    body :message => message
    headers "return-path" => "sistema@paraguayeduca.org" 
    content_type "text/html"
  end
  
  def fire_notification(notification, extended_data, destinations)
   
    recipients destinations
    from "sistema@paraguayeduca.org"
    subject notification.getName + (extended_data["subject"] ? " [#{extended_data["subject"]}]" : "") 
    body :message => notification.getDescription, :extended_data => extended_data.keys.map { |key| key.to_s+" "+extended_data[key].to_s }.join("<br>")
    headers "return-path" => "sistema@paraguayeduca.org" 
    content_type "text/html"
  end

end
