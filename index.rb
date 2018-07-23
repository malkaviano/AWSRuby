module AWSRuby
    require 'aws-sdk-s3'
    require 'aws-sdk-ec2'
    require_relative 'lib/spot_client'
    require_relative 'lib/load_confs'
    require_relative 'lib/announcer'
    require_relative 'lib/appraiser'

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

        spot_client = SpotClient.new(ec2)

        { 
            spot_client: spot_client,
            region: region,
            product_descriptions: product_descriptions,
            ebs_cost: ebs_cost_per_gb,
            confs: LoadConfs.cluster_confs
        }
    end
    
    def self.run
        args = setup        

        spot_client = args[:spot_client]
        product_descriptions = args[:product_descriptions]
        confs = args[:confs]
        ebs_cost = args[:ebs_cost]

        instances_history = spot_client.history_for(confs.map {|conf| conf.instance_type}, product_descriptions)

        min_prices, best_conf = Appraiser.conf_costs(confs, ebs_cost, instances_history)

        Announcer.list_confs_min_prices(min_prices)

        Announcer.print_min_cost_conf(best_conf)
    end    

    run
end