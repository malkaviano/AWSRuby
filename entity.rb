module AWSRuby
    class Entity
        def initialize(params)
            params.each do |key, value|
                instance_variable_set("@#{key}".to_sym, value)

                self.class.send(:define_method, "#{key}=".to_sym) do |value|
                    instance_variable_set("@" + key.to_s, value)
                end

                self.class.send(:define_method, key.to_sym) do
                    instance_variable_get("@" + key.to_s)
                end
            end
        end
    end
end