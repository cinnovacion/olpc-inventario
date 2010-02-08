module ImageMagickWrapper

  class ConvertNotFoundError < StandardError
  end

   # call imagemagick library on commandline thus bypassing RMagick
   # memory leak hasseles :)
   def convert_to_png(src, out)
     #more options : convert +antialias -density 150 eps png
     ret = system("convert  #{src} #{out}")
     raise ConvertNotFoundError if !ret
   end
end
