CfhighlanderTemplate do
  DependsOn 'vpc@1.2.0'
  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true
    MappingParam('InstanceType') do
      map 'EnvironmentType'
      attribute 'AmqInstanceType'
    end
    maximum_availability_zones.times do |az|
      ComponentParam "SubnetCompute#{az}"
    end
  end
end
