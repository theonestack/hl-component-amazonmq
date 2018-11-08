CloudFormation do

  Description "#{component_name} - #{component_version}"

  az_conditions_resources('SubnetPersistence', maximum_availability_zones)

  Condition('IsMultiAZ', FnEquals(Ref('EnableMultiAZ'), 'true'))

  safe_component_name = component_name.capitalize.gsub('_','').gsub('-','')

  sg_tags = []
  sg_tags << { Key: 'Environment', Value: Ref(:EnvironmentName)}
  sg_tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType)}
  sg_tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{component_name}")}

  extra_tags.each { |key,value| sg_tags << { Key: "#{key}", Value: FnSub(value) } } if defined? extra_tags

  EC2_SecurityGroup("SecurityGroup#{safe_component_name}") do
    GroupDescription FnSub("${EnvironmentName}-#{component_name}")
    VpcId Ref('VPCId')
    Tags sg_tags
  end

  security_groups.each do |name, sg|
    sg['ports'].each do |port|
      EC2_SecurityGroupIngress("#{name}SGRule#{port['from']}") do
        Description FnSub("Allows #{port['from']} from #{name}")
        IpProtocol 'tcp'
        FromPort port['from']
        ToPort port.key?('to') ? port['to'] : port['from']
        GroupId FnGetAtt("SecurityGroup#{safe_component_name}",'GroupId')
        SourceSecurityGroupId sg.key?('stack_param') ? Ref(sg['stack_param']) : Ref(name)
      end
    end if sg.key?('ports')
  end if defined? security_groups

  if (defined? amq_config) && !(amq_config.nil?)
    AmazonMQ_Configuration(:Config) {
      Name FnSub("${EnvironmentName}-#{component_name}")
      EngineType engine_version
      EngineVersion 'ACTIVEMQ'
      Data(FnBase64(amq_config))
    }
  end

  single_az_subnets = [Ref("SubnetPersistence0")]
  multi_az_subnets = [Ref("SubnetPersistence0"),Ref("SubnetPersistence1")]

  amq_users=[]
  users.each do |user|
    user_object={}
    user_object[:Password] = Ref("#{user['username']}AMQPassword")
    user_object[:Username] = user['username']
    user_object[:ConsoleAccess] = user['console_access'] if user.has_key?('console_access')
    user_object[:Groups] = user['groups'] if user.has_key?('groups')
    amq_users << user_object
  end

  AmazonMQ_Broker(:Broker) {
    AutoMinorVersionUpgrade true
    BrokerName FnSub("${EnvironmentName}-#{component_name}")
    EngineType 'ACTIVEMQ'
    EngineVersion engine_version
    HostInstanceType Ref('InstanceType')
    Logs({
      Audit: logging['audit'],
      General: logging['general']
    })

    if (defined? amq_config) && !(amq_config.nil?)
      Configuration({
        Id: FnGetAtt(:Config, :Id),
        Revision: FnGetAtt(:Config, :Revision)
      })
    end

    DeploymentMode FnIf('IsMultiAZ', 'ACTIVE_STANDBY_MULTI_AZ', 'SINGLE_INSTANCE')
    PubliclyAccessible publicly_accessable

    SecurityGroups [ Ref("SecurityGroup#{safe_component_name}") ]
    SubnetIds FnIf('IsMultiAZ', multi_az_subnets, single_az_subnets)

    Users amq_users

    if defined? maintenance_window
      MaintenanceWindowStartTime({
        DayOfWeek: maintenance_window['day'],
        TimeOfDay: maintenance_window['time'],
        TimeZone: maintenance_window['timezone']
      })
    end

  }

  Route53_RecordSet(:AMQHostRecord) do
    HostedZoneName FnSub('${EnvironmentName}.${DnsDomain}.')
    Name FnSub("#{hostname}.${EnvironmentName}.${DnsName}.")
    Type 'CNAME'
    TTL '60'
    ResourceRecords [ FnSub('${Broker}-${Broker.ConfigurationRevision}.mq.${AWS::Region}.amazonaws.com') ]
  end

  Output(:BrokerID) { Value(Ref(:Broker)) }

end
