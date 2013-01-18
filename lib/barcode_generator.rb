# BarcodeGenerator
# uses Gbarcode for encoding barcode data and then rmagick to generate
# images out of it for displaying in views.
# Based on the old rails plugin https://github.com/anujluthra/barcode-generator/

module ActionView
  class Base
    VALID_BARCODE_OPTIONS = [:encoding_format, :output_format, :width, :height, :scaling_factor, :xoff, :yoff, :margin, :resolution, :antialias	]
    DEFAULT_ENCODING = Gbarcode::BARCODE_39 | Gbarcode::BARCODE_NO_CHECKSUM
    DEFAULT_FORMAT = 'png'
    DEFAULT_WIDTH = 200
    DEFAULT_HEIGHT = 50

    class ConvertNotFoundError < StandardError
    end

    def gs_convert(format, src, out)
      device="jpeg"
      device = "pnggray" if format == "png"

      ret = system("gs -q -r250 -dEPSCrop -dSAFER -dBATCH -dNOPAUSE -sDEVICE=#{device} -sOutputFile=#{out} #{src}")
      raise ConvertNotFoundError if !ret
    end

    def barcode(id, options = {:encoding_format => DEFAULT_ENCODING })
      options.assert_valid_keys(VALID_BARCODE_OPTIONS)
      options[:width] = DEFAULT_WIDTH unless options[:width]
      options[:height] = DEFAULT_HEIGHT unless options[:height]

      output_format = options[:output_format] ? options[:output_format] : DEFAULT_FORMAT

      id.upcase!
      # This gives us a partitioned path so as not to have thousands
      # of files in the same directory.  Also, put the files in
      # public system since capistrano symlinks this path across
      # deployments by default
      path = Rails.root.join('public', 'system', 'barcodes', *Digest::MD5.hexdigest(id).first(9).scan(/.../))
      FileUtils.mkdir_p(path)
      eps = "#{path}/#{id}.eps"
      out = "#{path}/#{id}.#{output_format}"
      
      #dont generate a barcode again, if already generated
      unless File.exists?(out)
        #generate the barcode object with all supplied options
        options[:encoding_format] = DEFAULT_ENCODING unless options[:encoding_format]
        bc = Gbarcode.barcode_create(id)
        bc.width  = options[:width]
        bc.height = options[:height]
        bc.scalef = options[:scaling_factor] if options[:scaling_factor]
        bc.xoff   = options[:xoff]           if options[:xoff]
        bc.yoff   = options[:yoff]           if options[:yoff]
        bc.margin = options[:margin]         if options[:margin]
        Gbarcode.barcode_encode(bc, options[:encoding_format])
        
        if options[:no_ascii]
          print_options = Gbarcode::BARCODE_OUT_EPS|Gbarcode::BARCODE_NO_ASCII
        else
          print_options = Gbarcode::BARCODE_OUT_EPS
        end
        
        #encode the barcode object in desired format
        File.open(eps,'wb') do |eps_img| 
          Gbarcode.barcode_print(bc, eps_img, print_options)
          eps_img.close
          gs_convert(output_format, eps, out)
        end

        # delete the eps image, no need to accummulate cruft
        File.delete(eps)
      end
      #send the html image tag
      image_tag(out.gsub(/.*public\/system/, '/system'), :width => options[:width], :height => options[:height])
    end

  end
end
