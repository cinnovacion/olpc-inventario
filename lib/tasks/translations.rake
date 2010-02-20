# # #
#
# This task updates .po files (used for translations)
#
# Author: Raul Gutierrez S. - rgs@paraguayeduca.org
#

require 'gettext/tools'

namespace :translations do
  desc "Update files needed for translations"

  task(:update_pofiles => :environment) do
    domain = "inventario"
    files = Dir.glob("{app,lib}/**/*.{rb,rhtml}")
    app_version = "0.3" # we should parse this from the .spec
    opts = { :po_root => "translation/po" }

    GetText.update_pofiles(domain, files, app_version, opts)
  end

end

namespace :translations do
  desc "Create the mo files"

  task(:update_mofiles => :environment) do
    GetText.create_mofiles(:po_root => "translation/po", :mo_root => "translation/locale", :verbose => true)
  end

end
