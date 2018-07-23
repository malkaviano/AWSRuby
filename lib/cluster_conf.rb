module AWSRuby
    require_relative 'value'

    class ClusterConf
        include Value
        
        def initialize(params)
            super
        end        

        def self.customer_etl
            [
                ClusterConf.new("instance_type" => "r3.2xlarge", "nodes" => 20, "ebs" => 0),
                ClusterConf.new("instance_type" => "r3.4xlarge", "nodes" => 15, "ebs" => 0),
                ClusterConf.new("instance_type" => "r3.8xlarge", "nodes" => 10, "ebs" => 0),
        
                ClusterConf.new("instance_type" => "r4.16xlarge", "nodes" => 5, "ebs" => 40),
                ClusterConf.new("instance_type" => "r4.8xlarge", "nodes" => 10, "ebs" => 40),
                ClusterConf.new("instance_type" => "r4.4xlarge", "nodes" => 15, "ebs" => 40),
                ClusterConf.new("instance_type" => "r4.2xlarge", "nodes" => 20, "ebs" => 40),
        
                ClusterConf.new("instance_type" => "g3.8xlarge", "nodes" => 10, "ebs" => 40),
                ClusterConf.new("instance_type" => "g3.4xlarge", "nodes" => 15, "ebs" => 40),
        
                ClusterConf.new("instance_type" => "m2.4xlarge", "nodes" => 15, "ebs" => 0),
        
                ClusterConf.new("instance_type" => "p3.2xlarge", "nodes" => 20, "ebs" => 40),
                ClusterConf.new("instance_type" => "p3.8xlarge", "nodes" => 10, "ebs" => 40),
        
                ClusterConf.new("instance_type" => "p2.8xlarge", "nodes" => 10, "ebs" => 40),
        
                ClusterConf.new("instance_type" => "cr1.8xlarge", "nodes" => 10, "ebs" => 0),
        
                ClusterConf.new("instance_type" => "d2.2xlarge", "nodes" => 20, "ebs" => 0),
                ClusterConf.new("instance_type" => "d2.4xlarge", "nodes" => 15, "ebs" => 0),
                ClusterConf.new("instance_type" => "d2.8xlarge", "nodes" => 10, "ebs" => 0),
        
                ClusterConf.new("instance_type" => "i3.2xlarge", "nodes" => 20, "ebs" => 0),
                ClusterConf.new("instance_type" => "i3.4xlarge", "nodes" => 15, "ebs" => 0),
                ClusterConf.new("instance_type" => "i3.8xlarge", "nodes" => 10, "ebs" => 0),
            ]
        end
    end    
end