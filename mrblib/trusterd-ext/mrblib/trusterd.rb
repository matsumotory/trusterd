module HTTP2
  class Server
    def location arg, &b
      if uri =~ /#{arg}/
        b.call
      end
    end
    def file arg, &b
      if filename =~ /#{arg}/
        b.call
      end
    end
  end
end
