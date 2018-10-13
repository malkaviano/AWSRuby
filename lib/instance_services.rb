module AWSRuby
    class InstanceServices
        def initialize(ec2)
            @ec2 = ec2
        end

        def spot_price_history(filter:)
            resp = @ec2.describe_spot_price_history(filter)
                        .to_h[:spot_price_history]

            resp.group_by {|history| history[:instance_type] }.freeze
        end

        def terminate_instances(ids:)
            @ec2.terminate_instances({ instance_ids: ids }).to_h.freeze
        end
    end
end