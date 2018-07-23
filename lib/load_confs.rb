module AWSRuby
    require 'json'
    require_relative 'cluster_conf'

    module LoadConfs
        class << self
            def cluster_confs
                path = File.join(File.dirname(__FILE__), '../json/cluster_confs.json')

                file = File.read(path)

                JSON.parse(file).map do |line|
                    ClusterConf.new(line)
                end
            end
        end
    end
end