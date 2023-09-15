CloudFormation do

  Description "#{component_name} - #{component_version}"

  Condition('IsMultiAZ', FnEquals(Ref('EnableMultiAZ'), 'true'))

  safe_component_name = component_name.capitalize.gsub('_','').gsub('-','')
  export = defined?(export_name) ? export_name : component_name

  sg_tags = []
  sg_tags << { Key: 'Environment', Value: Ref(:EnvironmentName)}
  sg_tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType)}
  sg_tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{component_name}")}

  extra_tags.each { |key,value| sg_tags << { Key: "#{key}", Value: FnSub(value) } } if defined? extra_tags

  EC2_SecurityGroup("SecurityGroup#{safe_component_name}") do
    GroupDescription FnSub("${EnvironmentName}-#{component_name}")
    VpcId Ref('VPCId')
    SecurityGroupIngress generate_security_group_rules(security_group_rules,ip_blocks) if defined? security_group_rules
    Tags sg_tags
    Metadata({
      cfn_nag: {
        rules_to_suppress: [
          { id: 'F1000', reason: 'adding rules using cfn resources' }
        ]
      }
    })
  end

  Output(:SecurityGroup) {
    Value(Ref("SecurityGroup#{safe_component_name}"))
    Export FnSub("${EnvironmentName}-#{export}-SecurityGroup")
  }

  # Plan to be depreciated at a further point
  security_groups.each do |name, sg|
    sg['ports'].each do |port|

      EC2_SecurityGroupIngress("#{name}SGRule#{port['from']}") do
        Description FnSub("Allows #{port['from']} from #{name}")
        IpProtocol 'tcp'
        FromPort port['from']
        ToPort port.key?('to') ? port['to'] : port['from']
        GroupId FnGetAtt("SecurityGroup#{safe_component_name}",'GroupId')
        SourceSecurityGroupId sg.key?('stack_param') ? Ref(sg['stack_param']) : Ref(name) unless sg.has_key?('cidrip')
        CidrIp sg['cidrip'] if sg.has_key?('cidrip')
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

  single_az_subnet = [FnSelect(0, Ref('SubnetIds'))]
  multi_az_subnets = [FnSelect(0, Ref('SubnetIds')), FnSelect(1, Ref('SubnetIds'))]

  amq_users=[]
  users.each do |user|

    username_key = user.has_key?('username_key') ? user['username_key'] : 'username'
    password_key = user.has_key?('password_key') ? user['password_key'] : 'password'
    Resource("#{user['username']}SSMSecureParameter") {
      Type "Custom::SSMSecureParameter"
      Property('ServiceToken', FnGetAtt('SSMSecureParameterCR', 'Arn'))
      Property('Length', user['password_length']) if user.has_key?('password_length')
      Property('Path', FnSub("#{user['ssm_path']}/#{password_key}"))
      Property('Description', FnSub("${EnvironmentName} AMQ User #{user['username']} Password"))
      Property('Tags',[
        { Key: 'Name', Value: FnSub("${EnvironmentName}-#{user['username']}-amq-password")},
        { Key: 'Environment', Value: FnSub("${EnvironmentName}")},
        { Key: 'EnvironmentType', Value: FnSub("${EnvironmentType}")}
      ])
    }

    SSM_Parameter("#{user['username']}ParameterSecretKey") {
      Name FnSub("#{user['ssm_path']}/#{username_key}")
      Type 'String'
      Value "#{user['username']}"
    }

    user_object={}
    user_object[:Password] = FnGetAtt("#{user['username']}SSMSecureParameter","Password")
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
    SubnetIds FnIf('IsMultiAZ', multi_az_subnets, single_az_subnet)

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
    Name FnSub("#{hostname}.${EnvironmentName}.${DnsDomain}.")
    Type 'CNAME'
    TTL '60'
    ResourceRecords [ FnSub('${Broker}-1.mq.${AWS::Region}.amazonaws.com') ]
  end

  Output(:BrokerID) { 
    Value Ref(:Broker)
    Export FnSub("${EnvironmentName}-#{export}-broker-id")
  }
  
  Output(:OpenWireEndpoints) { 
    Value FnJoin(',', FnGetAtt(:Broker, :OpenWireEndpoints))
    Export FnSub("${EnvironmentName}-#{export}-openwire-endpoint-1")
  }

end
