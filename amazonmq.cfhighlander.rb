CfhighlanderTemplate do

  Name "AmazonMQ"

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true
    ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'InstanceType', 'mq.t2.micro'
    ComponentParam 'EnableMultiAZ', false
    ComponentParam 'SubnetIds', type: 'CommaDelimitedList'

    security_groups.each do |name, sg|
      ComponentParam name
    end if defined? security_groups

    ComponentParam 'DnsDomain'

  end

  LambdaFunctions 'ssm_custom_resources'

end
