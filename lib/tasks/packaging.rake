namespace :packaging do
  desc "Packaging"

  task(:buildrpm => :environment) do
    version = `grep Version #{Rails.root}/packaging/inventario.spec`.strip!
    vsplit = version.split(" ", 2)
    version = vsplit[1]
    system "git archive --format=tar --prefix=inventario-#{version}/ HEAD | gzip > #{Rails.root}/packaging/inventario-#{version}.tar.gz"
    system "rpmbuild -ba packaging/inventario.spec --define \"_sourcedir #{Rails.root}/packaging\""
  end
end
