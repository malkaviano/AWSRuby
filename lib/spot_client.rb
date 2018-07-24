module AWSRuby
    class SpotClient
        def initialize(ec2)
            @ec2 = ec2
        end

        def history_for(spot_history_filters)
            resp = @ec2.describe_spot_price_history(spot_history_filters)
                        .spot_price_history
    
            resp.group_by {|history| history.instance_type }
        end        
    end
end