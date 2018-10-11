module AWSRuby
    require 'json'

    class ConfigLoader
        def initialize(config_dir)
            @config_dir = config_dir
        end

        def cluster_conf(name)
            loadFile(name, 'clusters', '.json')
        end

        def filter_conf(name)
            loadFile(name, 'filters', '.json').pop || {}
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

            File.open(path, "r").each { |line| result.push JSON.parse(line) }

            result
        end
    end
end