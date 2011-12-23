namespace :gui do
  task :generate, :task do |t, args|
    task = args[:task] || "source"
    Dir.chdir "public/gui" do
      system "./generate.py #{task}"
    end
    if system("selinuxenabled")
      system("chcon -R -h -t httpd_sys_content_t public/build")
    end
  end
end
