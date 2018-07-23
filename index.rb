module AWSRuby
    require 'aws-sdk-s3'
    require 'aws-sdk-ec2'
    require_relative 'lib/ec2_instance_helper'
    require_relative 'lib/cluster_conf'
    require_relative 'lib/ec2_instance_info'    
    require_relative 'lib/announcer'

    def self.setup
        throw RuntimeError("ENV credentials not set!") if ENV['AWS_ACCESS_KEY_ID'].nil? || ENV['AWS_SECRET_ACCESS_KEY'].nil?

        Aws.config.update({
            credentials: Aws::Credentials.new(
                ENV['AWS_ACCESS_KEY_ID'],
                ENV['AWS_SECRET_ACCESS_KEY']
            )
        })
    
        region = ENV['REGION'] || 'us-east-1'
    
        product_descriptions = [ "Linux/UNIX (Amazon VPC)" ]

        ec2 = Aws::EC2::Client.new(region: region)

        # cost * (Estimation of 6h job / (day seconds * month))
        ebs_cost_per_gb = 0.1 * (21600.0 / (86400 * 30))

        ec2_instance_helper = EC2InstanceHelper.new(ec2)

        [ ec2_instance_helper, region, product_descriptions, ebs_cost_per_gb ]
    end    

    def self.list_conf_cost
        ec2_instance_helper, region, product_descriptions, ebs_cost_per_gb = setup

        confs = ClusterConf.customer_etl

        instances_history = ec2_instance_helper.history_for(confs.map {|conf| conf.instance_type}, product_descriptions)

        instances_info = ec2_instance_helper.history_to_info(instances_history)

        instances_min_price = ec2_instance_helper.min_price(instances_info)
        
        

        result = instances_min_price.map do |instance_type, a|
            result = confs.select {|cluster_conf| cluster_conf.instance_type == instance_type}.pop

            zone = a[0]
            price = a[1]

            total = ClusterConf.total_cost(result.nodes, price, result.ebs, ebs_cost_per_gb)                    

            { instance_type: instance_type, zone: zone, nodes: result.nodes, ebs: result.ebs, cost: total }
        end

        best = [ result.min {|i1, i2| i1[:cost] <=> i2[:cost] } ]

        [ result, best ]
    end

    min_prices, best_conf = list_conf_cost

    Announcer.list_confs_min_prices(min_prices)

    Announcer.print_min_cost_conf(best_conf)
end