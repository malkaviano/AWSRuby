module AWSRuby
    require_relative 'spot_info'

    module Appraiser
        class << self
            def lower_cost_conf(instances_with_cost, confs, ebs_cost_per_gb, include_master = true)
                hash = {}

                confs.each do |conf|
                    zone, price = instances_with_cost[conf.instance_type]

                    num = include_master ? (conf.nodes + 1) : conf.nodes

                    total = total_cost(num, price, conf.ebs, ebs_cost_per_gb)

                    hash[total] = [conf.instance_type, zone]
                end

                hash.min_by {|key, value| key}.flatten
            end

            def total_cost(num, price, ebsGB, ebs_cost_per_gb)
                (num * (price + (ebsGB * ebs_cost_per_gb))).round(2)
            end

            def conf_costs(confs, ebs_cost_per_gb, instances_history)
                instances_info = history_to_info(instances_history)
        
                instances_min_price = min_price(instances_info)
        
                result = instances_min_price.map do |instance_type, a|
                    result = confs.select {|cluster_conf| cluster_conf.instance_type == instance_type}.pop
        
                    zone = a[0]
                    price = a[1]
        
                    total = total_cost(result.nodes, price, result.ebs, ebs_cost_per_gb)                    
        
                    { instance_type: instance_type, zone: zone, nodes: result.nodes, ebs: result.ebs, cost: total }
                end
        
                best = [ result.min {|i1, i2| i1[:cost] <=> i2[:cost] } ]
        
                [ result, best ]
            end
            
            def history_to_info(instances_history)
                instances_history.map do |key, value|
                    spot_price = 0
                    num = 0
            
                    instance = SpotInfo.new(
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
end