module AWSRuby    
    module Announcer
        require 'logger'

        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO

        class << self
            def list_confs_min_prices(params)
                @logger.info("Listing best price for all configs")

                print_confs(params)
            end

            def print_min_cost_conf(params)
                @logger.info("Cheapest config at the moment:")

                print_confs(params)
            end

            def print_cluster_info(cluster_info)
                cluster_info.each_with_index do |hash, i|
                    @logger.info("Instance: #{i + 1}")
                    hash.each {|key, value| @logger.info("#{key}: #{value}") }                
                end
    
                @logger.info("Total: #{cluster_info.count}")
            end

            private

            def print_confs(params)
                params.each do |argument|                
                    @logger.info("Instance type: #{argument[:instance_type]} - Zone: #{argument[:zone]} - Nodes: #{argument[:nodes]} with #{argument[:ebs]}GB EBS costing #{argument[:cost]}$/hour")
                end
            end
        end
    end
end