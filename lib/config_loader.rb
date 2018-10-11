module AWSRuby
    require 'json'
    require_relative 'data/cluster_conf'

    class ConfigLoader
        def initialize(config_dir)
            @config_dir = config_dir
        end

        def cluster_conf(name)
            result = []

            return result if !(name.is_a? String) or name.empty?

            unless File.extname(name) == ".json" then
                name += ".json"
            end

            path = File.join(@config_dir, 'cluster', name)

            return result unless File.exists? path

            File.open(path, "r").each { |line| result.push JSON.parse(line) }

            result
        end
    end
end