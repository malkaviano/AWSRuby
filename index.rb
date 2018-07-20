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

        # Estimation of 6h job
        ebs_cost_per_gb = 0.1 * (21600.0 / (86400 * 30))

        [ ec2, region, product_descriptions, ebs_cost_per_gb ]
    end

    def self.run
        ec2, region, product_descriptions, ebs_cost_per_gb = setup

        ec2_instance_helper = EC2InstanceHelper.new(ec2)

        confs = ClusterConf.customer_etl

        instances_history = ec2_instance_helper.history_for(confs.map {|conf| conf.instance_type}, product_descriptions)

        instances_info = ec2_instance_helper.history_to_info(instances_history)

        instances_min_price = ec2_instance_helper.min_price(instances_info)

        conf = ClusterConf.lower_cost_conf(instances_min_price, confs, ebs_cost_per_gb)

        p conf

        p instances_min_price

        p instances_info
    end

    run
end