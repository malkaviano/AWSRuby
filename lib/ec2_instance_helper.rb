module AWSRuby
    class EC2InstanceHelper
        def initialize(ec2)
            @ec2 = ec2
        end

        def history_for(instance_types, product_descriptions)
            t = Time.now

            resp = @ec2.describe_spot_price_history({
                start_time: t - (60 * 60 * 6),
                end_time: t + (60 * 60 * 24), 
                instance_types: instance_types, 
                product_descriptions: product_descriptions
            })
    
            resp.spot_price_history.group_by {|history| history.instance_type }
        end

        def history_to_info(instances_history)
            instances_history.map do |key, value|
                spot_price = 0
                num = 0
        
                instance = EC2InstanceInfo.new(
                    "instance_type" => key,
                    "spot_prices" => {}
                )
        
                value.group_by {|info| info.availability_zone }.map do |zone, info|
                    info.map do |instance|
                        spot_price += instance.spot_price.to_f
                        num += 1
                    end

                    instance.spot_prices[zone] = spot_price / num 
                end
        
                instance
            end.flatten
        end

        def min_price(instances_info)
            hash = {}

            instances_info.each do |instance|
                hash[instance.instance_type] = instance.spot_prices.min_by { |zone, price| price }
            end

            hash
        end
    end
end