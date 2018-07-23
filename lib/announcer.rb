module AWSRuby
    module Announcer
        def self.list_confs_min_prices(args)
            puts "Listing best price for all configs"

            print_confs(args)
        end

        def self.print_min_cost_conf(args)
            puts "\nCheapest config at the moment:"

            print_confs(args)
        end

        private

        def self.print_confs(args)
            args.each do |argument|                
                puts "Instance type: #{argument[:instance_type]} - Zone: #{argument[:zone]} - Nodes: #{argument[:nodes]} with #{argument[:ebs]}GB EBS costing #{argument[:cost]}$/hour"
            end
        end
    end
end