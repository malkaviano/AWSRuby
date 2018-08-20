module AWSRuby
    class ClusterMonitor
        def initialize(ec2)
            @ec2 = ec2
        end

        def cluster_info(filters)
            result = @ec2.describe_instances({filters: filters})

            result.reservations.map do |reservation|
                reservation.instances.map do |instance|
                    hash = {}

                    hash.store("instance_id", instance.instance_id)
                    hash.store("image_id", instance.image_id)
                    hash.store("instance_type", instance.instance_type)
                    hash.store("key_name", instance.key_name)
                    hash.store("launch_time", instance.launch_time)
                    hash.store("availability_zone", instance.placement.availability_zone)
                    hash.store("private_ip_address", instance.private_ip_address)
                    hash.store("public_ip_address", instance.public_ip_address)
                    hash.store("state_code", instance.state.code)
                    hash.store("state_name", instance.state.name)
                    hash.store("subnet_id", instance.subnet_id)
                    hash.store("ebs_optimized", instance.ebs_optimized)
                    hash.store("instance_lifecycle", instance.instance_lifecycle)
                    hash.store("virtualization_type", instance.virtualization_type)
                    hash.store("core_count", instance.cpu_options.core_count)
                    hash.store("threads_per_core", instance.cpu_options.threads_per_core)

                    sg = []
                    instance.security_groups.each do |group|
                        sg.push({group.group_id => group.group_name})
                    end

                    hash.store("security_groups", sg)

                    tags = []
                    instance.tags.each do |tag|
                        tags.push({tag.key => tag.value})
                    end

                    hash.store("tags", tags)

                    ebs = []
                    instance.block_device_mappings.each do |device|
                        ebs.push({"attach_time" => device.ebs.attach_time})
                        ebs.push({"delete_on_termination" => device.ebs.delete_on_termination})
                        ebs.push({"volume_id" => device.ebs.volume_id})
                    end

                    hash.store("ebs", ebs)

                    hash
                end
            end.flatten
        end
    end
end