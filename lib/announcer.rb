module AWSRuby
    module Announcer
        class << self
            def list_confs_min_prices(params)
                puts "Listing best price for all configs"

                print_confs(params)
            end

            def print_min_cost_conf(params)
                puts "\nCheapest config at the moment:"

                print_confs(params)
            end

            private

            def print_confs(params)
                params.each do |argument|                
                    puts "Instance type: #{argument[:instance_type]} - Zone: #{argument[:zone]} - Nodes: #{argument[:nodes]} with #{argument[:ebs]}GB EBS costing #{argument[:cost]}$/hour"
                end
            end
        end
    end
end