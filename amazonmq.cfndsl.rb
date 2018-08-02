CloudFormation do

  Description "#{component_name} - #{component_version}"

  az_conditions_resources('SubnetCompute', maximum_availability_zones)

  AmazonMQ_Configuration(:config) do
    Data ''
    EngineType engine_type
    EngineVersion engine_version
    Name name
  end

end
