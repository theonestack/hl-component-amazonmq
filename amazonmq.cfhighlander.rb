CfhighlanderTemplate do

  Name "AmazonMQ"

  DependsOn 'vpc'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true
    ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'InstanceType', 'mq.t2.micro'
    ComponentParam 'EnableMultiAZ', false

    security_groups.each do |name, sg|
      ComponentParam name
    end if defined? security_groups

    users.each do |user|
      ComponentParam "#{user['username']}AMQPassword", 'administrator', noEcho: true
    end

    maximum_availability_zones.times do |az|
      ComponentParam "SubnetPersistence#{az}"
    end

    ComponentParam 'DnsDomain'

  end

end
