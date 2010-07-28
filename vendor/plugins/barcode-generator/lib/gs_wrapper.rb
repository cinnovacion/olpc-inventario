module GsWrapper

  class ConvertNotFoundError < StandardError
  end

   def gs_convert(format, src, out)
     device="jpeg"
     if format == "png"
       device="pnggray"
     end

     ret = system("gs -q -r250 -dEPSCrop -dSAFER -dBATCH -dNOPAUSE -sDEVICE=#{device} -sOutputFile=#{out} #{src}")
     raise ConvertNotFoundError if !ret
   end
end
