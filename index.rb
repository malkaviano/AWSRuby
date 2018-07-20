module AWSRuby
    require 'aws-sdk-s3'
    require 'aws-sdk-ec2'
    require_relative 'lib/ec2_instance_helper'
    require_relative 'lib/cluster_conf'
    require_relative 'lib/ec2_instance_info'    

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

    def self.cheapest_conf
        ec2_instance_helper, region, product_descriptions, ebs_cost_per_gb = setup

        confs = ClusterConf.customer_etl

        instances_history = ec2_instance_helper.history_for(confs.map {|conf| conf.instance_type}, product_descriptions)

        instances_info = ec2_instance_helper.history_to_info(instances_history)

        instances_min_price = ec2_instance_helper.min_price(instances_info)

        conf = ClusterConf.lower_cost_conf(instances_min_price, confs, ebs_cost_per_gb)

        result = confs.select {|cluster_conf| cluster_conf.instance_type == conf[1]}.pop
        
        puts "Cheapest config at the moment:"

        puts "Instance type: #{conf[1]} - Zone: #{conf[2]} - Nodes: #{result.nodes} with #{result.ebs}GB EBS costing #{conf[0]}$/hour"
    end

    def self.list_conf_cost
        ec2_instance_helper, region, product_descriptions, ebs_cost_per_gb = setup

        confs = ClusterConf.customer_etl

        instances_history = ec2_instance_helper.history_for(confs.map {|conf| conf.instance_type}, product_descriptions)

        instances_info = ec2_instance_helper.history_to_info(instances_history)

        instances_min_price = ec2_instance_helper.min_price(instances_info)
        
        puts "Listing best price for all configs"

        result = instances_min_price.map do |instance_type, a|
            result = confs.select {|cluster_conf| cluster_conf.instance_type == instance_type}.pop

            zone = a[0]
            price = a[1]

            total = ClusterConf.total_cost(result.nodes, price, result.ebs, ebs_cost_per_gb)            
            
            puts "Instance type: #{instance_type} - Zone: #{zone} - Nodes: #{result.nodes} with #{result.ebs}GB EBS costing #{total}$/hour"

            [ instance_type, zone, result.nodes, result.ebs, total ]
        end

        r = result.min {|i1, i2| i1[4] <=> i2[4] }

        puts "\nCheapest config at the moment:"

        puts "Instance type: #{r[0]} - Zone: #{r[1]} - Nodes: #{r[2]} with #{r[3]}GB EBS costing #{r[4]}$/hour"

        [ result, r ]
    end

    list_conf_cost
end