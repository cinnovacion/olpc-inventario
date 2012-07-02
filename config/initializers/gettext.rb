Object.send(:include,FastGettext::Translation)
FastGettext.add_text_domain('inventario',:path=>'translation/locale',:type=>:po)
FastGettext.default_text_domain = 'inventario'
