CloudFormation do

  Description "#{component_name} - #{component_version}"

  az_conditions_resources('SubnetCompute', maximum_availability_zones)

end
