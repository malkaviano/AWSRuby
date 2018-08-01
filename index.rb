module AWSRuby
    require 'aws-sdk-s3'
    require 'aws-sdk-ec2'
    require_relative 'lib/spot_client'
    require_relative 'lib/load_confs'
    require_relative 'lib/announcer'
    require_relative 'lib/appraiser'
    require_relative 'lib/cluster_monitor'

    class << self
        def history_now
            t = Time.now.utc
            
            spot_history_filters = {
                start_time: t,
                end_time: t, 
                instance_types: @confs.map {|conf| conf.instance_type}, 
                product_descriptions: @product_descriptions
            }

            @spot_client.history_for(spot_history_filters)
        end

        def appraise_confs(instances_history)
            Appraiser.conf_costs(@confs, @ebs_cost, instances_history)
        end

        def cluster_running_info_for(tagNames)
            filters = [
                { name: 'tag:Name', values: tagNames },
                { name: 'instance-state-name', values: ['running'] }
            ]

            @cluster_monitor.cluster_info(filters)
        end

        def print_min_prices(min_prices)
            Announcer.list_confs_min_prices(min_prices)
        end

        def print_min_cost_conf(best_cost_conf)
            Announcer.print_min_cost_conf(best_cost_conf)
        end

        def print_cluster_info(cluster_info)
            Announcer.print_cluster_info(cluster_info)
        end

        def run
            setup

            instances_history = history_now

            min_prices, best = appraise_confs(instances_history)

            cluster_info = cluster_running_info_for(['crm-ignition-dev-raf'])

            ARGV.each do|a|
                case a
                when "print_min_prices"
                    print_min_prices(min_prices)
                when "print_min_cost_conf"
                    print_min_cost_conf(best)
                when "print_cluster_info"
                    print_cluster_info(cluster_info)
                else
                  puts "Wrong option"
                end
                
            end
        end

        private
        def setup
            throw RuntimeError("ENV credentials not set!") if ENV['AWS_ACCESS_KEY_ID'].nil? || ENV['AWS_SECRET_ACCESS_KEY'].nil?
    
            Aws.config.update({
                credentials: Aws::Credentials.new(
                    ENV['AWS_ACCESS_KEY_ID'],
                    ENV['AWS_SECRET_ACCESS_KEY']
                )
            })
        
            @region = ENV['REGION'] || 'us-east-1'
        
            @product_descriptions = [ "Linux/UNIX (Amazon VPC)" ]
    
            @ec2_client = Aws::EC2::Client.new(region: @region)
    
            # cost * (Estimation of 6h job / (day seconds * month))
            @ebs_cost = 0.1 * (21600.0 / (86400 * 30))
    
            @spot_client = SpotClient.new(@ec2_client)
    
            @cluster_monitor = ClusterMonitor.new(@ec2_client)        
    
            @confs = LoadConfs.cluster_confs
        end
    end      

    run
end