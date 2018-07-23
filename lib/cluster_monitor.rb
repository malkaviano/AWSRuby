module AWSRuby
    class ClusterMonitor
        def initialize(ec2)
            @ec2 = ec2
        end

        def cluster_info(cluster_name)
            # Get all instances with tag key 'spark_cluster_name'
            # and tag value $cluster_name:
            result = @ec2.instances({filters: [{name: 'tag:spark_cluster_name', values: [cluster_name]}]})
            
            result.map do |instance|
                hash = {}

                info = instance.data

                hash.store("image_id", info.image_id)
                hash.store("instance_type", info.instance_type)
                hash.store("key_name", info.key_name)
                hash.store("launch_time", info.launch_time)
                hash.store("availability_zone", info.placement.availability_zone)
                hash.store("private_ip_address", info.private_ip_address)
                hash.store("public_ip_address", info.public_ip_address)
                hash.store("state_code", info.state.code)
                hash.store("state_name", info.state.name)
                hash.store("subnet_id", info.subnet_id)
                hash.store("ebs_optimized", info.ebs_optimized)
                hash.store("instance_lifecycle", info.instance_lifecycle)
                hash.store("virtualization_type", info.virtualization_type)
                hash.store("core_count", info.cpu_options.core_count)
                hash.store("threads_per_core", info.cpu_options.threads_per_core)

                sg = []
                info.security_groups.each do |group|
                    sg.push({group.group_id => group.group_name})
                end
                
                hash.store("security_groups", sg)

                tags = []
                info.tags.each do |tag|
                    tags.push({tag.key => tag.value})
                end

                hash.store("tags", tags)

                ebs = []
                info.block_device_mappings.each do |device|
                    ebs.push({"attach_time" => device.ebs.attach_time})
                    ebs.push({"delete_on_termination" => device.ebs.delete_on_termination})
                    ebs.push({"volume_id" => device.ebs.volume_id})
                end

                hash.store("ebs", ebs)

                hash
            end
        end        
    end
end