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
    def setup_access_log config
      @log = Log.new config, self
    end
    def write_access_log format=nil
      @log.write format
    end
    class Log
      def initialize config, obj
        @s = obj
        @config = config
        @f = File.open @config[:file], "a"
      end
      def write format=nil
        if @config[:format] == :default
          if @config[:type] == :json
            @f.write default_format_json
          elsif @config[:type] == :plain
            @f.write default_format_plain
          else
            @f.write default_format_plain
          end
        else
          if format.nil?
            raise "setup log format when :format is not default"
          else
            @f.write format
          end
        end
      end
      def default_format_plain
        "#{@s.conn.client_ip} - - [#{@s.date}] \"#{@s.method} #{@s.unparsed_uri} HTTP/2\" #{@s.status} #{@s.content_length} \"-\" \"#{@s.user_agent}\"\n"
      end
      def default_format_json
        log = {
          :ip => @s.conn.client_ip,
          :date => @s.date,
          :scheme => @s.scheme,
          :mehtod => @s.method,
          :status => @s.status,
          :content_length => @s.content_length,
          :uri => @s.uri,
          :filename => @s.filename,
          :user_agent => @s.user_agent,
        }
        JSON.stringify(log) + "\n"
      end
    end
  end
end
