# Copyright One Laptop per Child 2013
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

class ConnectionEventsController < SearchController
  skip_filter :rpc_block, only: [:report_event]
  undef_method :delete
  undef_method :save

  def new
    event = prepare_form(window_title: "Connection event")
    form_details_link(_("Laptop:"), :laptops, event.laptop_id, event.laptop.serial_number)

    form_label(_("Connected at:"), event.connected_at)

    form_label(_("Notified as stolen:"), event.stolen ? _("Yes") : _("No"))

    form_label(_("IP address:"), event.ip_address) if event.ip_address
    if event.vhash
      version = event.software_version
      if version
        form_details_link(_("Software version:"), :software_versions, version.id, version.name)
      else
        form_label(_("Software version:"), _("Unknown: %{hash}") % {hash: event.vhash})
      end
    end

    if event.free_space
      space = event.free_space * 1024
      space = Object.new.extend(ActionView::Helpers::NumberHelper).number_to_human_size(space)
      form_label(_("Free disk space:"), space)
    end
  end

  def report_event
    laptop = Laptop.find_by_serial_number!(params[:laptop])
    attribs = params.slice(:ip_address, :free_space, :stolen, :vhash, :connected_at)

    begin
      laptop.connection_events.create!(attribs)
    rescue ActiveRecord::RecordNotUnique
      # silently ignore duplicates
    end

    head :ok
  end
end
