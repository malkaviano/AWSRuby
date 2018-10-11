module AWSRuby
    class InstanceMonitor
        def initialize(ec2)
            @ec2 = ec2
        end

        def instance_info(filters)
            return if filters.empty?

            @ec2.describe_instances(filters).to_h
        end
    end
end