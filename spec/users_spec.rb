require 'yaml'

describe 'compiled component amazonmq' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/users.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/users/amazonmq.compiled.yaml") }
  
  context "Resource" do

    
    context "SecurityGroupAmazonmq" do
      let(:resource) { template["Resources"]["SecurityGroupAmazonmq"] }

      it "is of type AWS::EC2::SecurityGroup" do
          expect(resource["Type"]).to eq("AWS::EC2::SecurityGroup")
      end
      
      it "to have property GroupDescription" do
          expect(resource["Properties"]["GroupDescription"]).to eq({"Fn::Sub"=>"${EnvironmentName}-AmazonMQ"})
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPCId"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-AmazonMQ"}}])
      end
      
    end
    
    context "administratorSSMSecureParameter" do
      let(:resource) { template["Resources"]["administratorSSMSecureParameter"] }

      it "is of type Custom::SSMSecureParameter" do
          expect(resource["Type"]).to eq("Custom::SSMSecureParameter")
      end
      
      it "to have property ServiceToken" do
          expect(resource["Properties"]["ServiceToken"]).to eq({"Fn::GetAtt"=>["SSMSecureParameterCR", "Arn"]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq({"Fn::Sub"=>"/amazonmq/administrator/password"})
      end
      
      it "to have property Description" do
          expect(resource["Properties"]["Description"]).to eq({"Fn::Sub"=>"${EnvironmentName} AMQ User administrator Password"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-administrator-amq-password"}}, {"Key"=>"Environment", "Value"=>{"Fn::Sub"=>"${EnvironmentName}"}}, {"Key"=>"EnvironmentType", "Value"=>{"Fn::Sub"=>"${EnvironmentType}"}}])
      end
      
    end
    
    context "administratorParameterSecretKey" do
      let(:resource) { template["Resources"]["administratorParameterSecretKey"] }

      it "is of type AWS::SSM::Parameter" do
          expect(resource["Type"]).to eq("AWS::SSM::Parameter")
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"/amazonmq/administrator/username"})
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("String")
      end
      
      it "to have property Value" do
          expect(resource["Properties"]["Value"]).to eq("administrator")
      end
      
    end
    
    context "supportSSMSecureParameter" do
      let(:resource) { template["Resources"]["supportSSMSecureParameter"] }

      it "is of type Custom::SSMSecureParameter" do
          expect(resource["Type"]).to eq("Custom::SSMSecureParameter")
      end
      
      it "to have property ServiceToken" do
          expect(resource["Properties"]["ServiceToken"]).to eq({"Fn::GetAtt"=>["SSMSecureParameterCR", "Arn"]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq({"Fn::Sub"=>"/amazonmq/support/password"})
      end
      
      it "to have property Description" do
          expect(resource["Properties"]["Description"]).to eq({"Fn::Sub"=>"${EnvironmentName} AMQ User support Password"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-support-amq-password"}}, {"Key"=>"Environment", "Value"=>{"Fn::Sub"=>"${EnvironmentName}"}}, {"Key"=>"EnvironmentType", "Value"=>{"Fn::Sub"=>"${EnvironmentType}"}}])
      end
      
    end
    
    context "supportParameterSecretKey" do
      let(:resource) { template["Resources"]["supportParameterSecretKey"] }

      it "is of type AWS::SSM::Parameter" do
          expect(resource["Type"]).to eq("AWS::SSM::Parameter")
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"/amazonmq/support/username"})
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("String")
      end
      
      it "to have property Value" do
          expect(resource["Properties"]["Value"]).to eq("support")
      end
      
    end
    
    context "applicationSSMSecureParameter" do
      let(:resource) { template["Resources"]["applicationSSMSecureParameter"] }

      it "is of type Custom::SSMSecureParameter" do
          expect(resource["Type"]).to eq("Custom::SSMSecureParameter")
      end
      
      it "to have property ServiceToken" do
          expect(resource["Properties"]["ServiceToken"]).to eq({"Fn::GetAtt"=>["SSMSecureParameterCR", "Arn"]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq({"Fn::Sub"=>"/amazonmq/application/password"})
      end
      
      it "to have property Description" do
          expect(resource["Properties"]["Description"]).to eq({"Fn::Sub"=>"${EnvironmentName} AMQ User application Password"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-application-amq-password"}}, {"Key"=>"Environment", "Value"=>{"Fn::Sub"=>"${EnvironmentName}"}}, {"Key"=>"EnvironmentType", "Value"=>{"Fn::Sub"=>"${EnvironmentType}"}}])
      end
      
    end
    
    context "applicationParameterSecretKey" do
      let(:resource) { template["Resources"]["applicationParameterSecretKey"] }

      it "is of type AWS::SSM::Parameter" do
          expect(resource["Type"]).to eq("AWS::SSM::Parameter")
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"/amazonmq/application/username"})
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("String")
      end
      
      it "to have property Value" do
          expect(resource["Properties"]["Value"]).to eq("application")
      end
      
    end
    
    context "Broker" do
      let(:resource) { template["Resources"]["Broker"] }

      it "is of type AWS::AmazonMQ::Broker" do
          expect(resource["Type"]).to eq("AWS::AmazonMQ::Broker")
      end
      
      it "to have property AutoMinorVersionUpgrade" do
          expect(resource["Properties"]["AutoMinorVersionUpgrade"]).to eq(true)
      end
      
      it "to have property BrokerName" do
          expect(resource["Properties"]["BrokerName"]).to eq({"Fn::Sub"=>"${EnvironmentName}-AmazonMQ"})
      end
      
      it "to have property EngineType" do
          expect(resource["Properties"]["EngineType"]).to eq("ACTIVEMQ")
      end
      
      it "to have property EngineVersion" do
          expect(resource["Properties"]["EngineVersion"]).to eq("5.15.6")
      end
      
      it "to have property HostInstanceType" do
          expect(resource["Properties"]["HostInstanceType"]).to eq({"Ref"=>"InstanceType"})
      end
      
      it "to have property Logs" do
          expect(resource["Properties"]["Logs"]).to eq({"Audit"=>false, "General"=>false})
      end
      
      it "to have property DeploymentMode" do
          expect(resource["Properties"]["DeploymentMode"]).to eq({"Fn::If"=>["IsMultiAZ", "ACTIVE_STANDBY_MULTI_AZ", "SINGLE_INSTANCE"]})
      end
      
      it "to have property PubliclyAccessible" do
          expect(resource["Properties"]["PubliclyAccessible"]).to eq(false)
      end
      
      it "to have property SecurityGroups" do
          expect(resource["Properties"]["SecurityGroups"]).to eq([{"Ref"=>"SecurityGroupAmazonmq"}])
      end
      
      it "to have property SubnetIds" do
          expect(resource["Properties"]["SubnetIds"]).to eq({"Fn::If"=>["IsMultiAZ", [{"Fn::Select"=>[0, {"Ref"=>"SubnetIds"}]}, {"Fn::Select"=>[1, {"Ref"=>"SubnetIds"}]}], [{"Fn::Select"=>[0, {"Ref"=>"SubnetIds"}]}]]})
      end
      
      it "to have property Users" do
          expect(resource["Properties"]["Users"]).to eq([{"Password"=>{"Fn::GetAtt"=>["administratorSSMSecureParameter", "Password"]}, "Username"=>"administrator", "ConsoleAccess"=>true}, {"Password"=>{"Fn::GetAtt"=>["supportSSMSecureParameter", "Password"]}, "Username"=>"support", "ConsoleAccess"=>true, "Groups"=>["support"]}, {"Password"=>{"Fn::GetAtt"=>["applicationSSMSecureParameter", "Password"]}, "Username"=>"application", "ConsoleAccess"=>false}])
      end
      
    end
    
    context "AMQHostRecord" do
      let(:resource) { template["Resources"]["AMQHostRecord"] }

      it "is of type AWS::Route53::RecordSet" do
          expect(resource["Type"]).to eq("AWS::Route53::RecordSet")
      end
      
      it "to have property HostedZoneName" do
          expect(resource["Properties"]["HostedZoneName"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}."})
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"amq.${EnvironmentName}.${DnsDomain}."})
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("CNAME")
      end
      
      it "to have property TTL" do
          expect(resource["Properties"]["TTL"]).to eq("60")
      end
      
      it "to have property ResourceRecords" do
          expect(resource["Properties"]["ResourceRecords"]).to eq([{"Fn::Sub"=>"${Broker}-1.mq.${AWS::Region}.amazonaws.com"}])
      end
      
    end
    
    context "LambdaRoleSSMParameterCustomResource" do
      let(:resource) { template["Resources"]["LambdaRoleSSMParameterCustomResource"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"lambda.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq("/")
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"cloudwatch-logs", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams", "logs:DescribeLogGroups"], "Resource"=>["arn:aws:logs:*:*:*"]}]}}, {"PolicyName"=>"ssm", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["ssm:AddTagsToResource", "ssm:DeleteParameter", "ssm:PutParameter", "ssm:GetParameters"], "Resource"=>[{"Fn::Sub"=>"arn:aws:ssm:${AWS::Region}:${AWS::AccountId}:parameter/*"}]}]}}])
      end
      
    end
    
    context "SSMSecureParameterCR" do
      let(:resource) { template["Resources"]["SSMSecureParameterCR"] }

      it "is of type AWS::Lambda::Function" do
          expect(resource["Type"]).to eq("AWS::Lambda::Function")
      end
      
      it "to have property Code" do
        expect(resource["Properties"]["Code"]["S3Bucket"]).to eq("")
        expect(resource["Properties"]["Code"]["S3Key"]).to start_with("/latest/SSMSecureParameterCR.amazonmq.latest")
      end
      
      it "to have property Environment" do
          expect(resource["Properties"]["Environment"]).to eq({"Variables"=>{}})
      end
      
      it "to have property Handler" do
          expect(resource["Properties"]["Handler"]).to eq("handler.lambda_handler")
      end
      
      it "to have property MemorySize" do
          expect(resource["Properties"]["MemorySize"]).to eq(128)
      end
      
      it "to have property Role" do
          expect(resource["Properties"]["Role"]).to eq({"Fn::GetAtt"=>["LambdaRoleSSMParameterCustomResource", "Arn"]})
      end
      
      it "to have property Runtime" do
          expect(resource["Properties"]["Runtime"]).to eq("python3.8")
      end
      
      it "to have property Timeout" do
          expect(resource["Properties"]["Timeout"]).to eq(5)
      end
      
    end
    
  end

end