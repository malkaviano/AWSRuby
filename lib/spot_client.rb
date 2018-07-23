module AWSRuby
    class SpotClient
        def initialize(ec2)
            @ec2 = ec2
        end

        def history_for(instance_types, product_descriptions)
            t = Time.now

            resp = @ec2.describe_spot_price_history({
                start_time: t,
                end_time: t + (60 * 60 * 24), 
                instance_types: instance_types, 
                product_descriptions: product_descriptions
            })
    
            resp.spot_price_history.group_by {|history| history.instance_type }
        end        
    end
end