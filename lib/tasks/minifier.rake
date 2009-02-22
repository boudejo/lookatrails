namespace :minifier do

  def minify(files)
    files.each do |file|
      cmd = "java -jar lib/yuicompressor-2.3.6.jar #{file} -o #{file}"
      puts cmd
      ret = system(cmd)
      raise "Minification failed for #{file}" if !ret
    end
  end

  desc "minify"
  task :minify => [:minify_js, :minify_css]

  desc "minify javascript"
  task :minify_js do
    minify(FileList['public/javascripts/**/*.js'])
  end

  desc "minify css"
  task :minify_css do
    minify(FileList['public/stylesheets/**/*.css'])
  end

end