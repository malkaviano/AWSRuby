module AWSRuby
    require 'json'

    class ConfigLoader
        def initialize(config_dir:)
            @config_dir = config_dir
        end

        def cluster_conf(name:)
            loadFile(name, 'clusters', '.json').freeze
        end

        def filter_conf(name:)
            (loadFile(name, 'filters', '.json').pop || {}).freeze
        end

        private
        def loadFile(name, folder, ext)
            result = []

            return result if !(name.is_a? String) or name.empty?

            unless File.extname(name) == ext then
                name += ext
            end

            path = File.join(@config_dir, folder, name)

            return result unless File.exists? path

            File.open(path, "r").each do |line|
                parsed = JSON.parse(line)

                result.push parsed.inject({}) {|h, a| h.store(a[0].to_sym, a[1]); h }
            end

            result
        end
    end
end