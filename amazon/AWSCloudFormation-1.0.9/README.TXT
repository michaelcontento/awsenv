AWS CloudFormation Command Line Tool
====================================

Installation:
-------------

1. Ensure that JAVA version 1.5 or higher is installed on your system: (java -version)
2. Unzip the deployment zip file
3. Set the following environment variables:
3.1 AWS_CLOUDFORMATION_HOME - The directory where the deployment files were copied to
        check with:
           Unix: ls ${AWS_CLOUDFORMATION_HOME}/bin should list cfn-create-stack  ...)
           Windows: dir %AWS_CLOUDFORMATION_HOME%\bin should list cfn-create-stack  ...)
3.2 JAVA_HOME - Java Installation home directory
4. Add ${AWS_CLOUDFORMATION_HOME}/bin (in Windows: %AWS_CLOUDFORMATION_HOME%\bin) to your path

Configuration:
--------------
                                                                                                                                                             
1. Create a credential file: The deployment includes an example file ${AWS_CLOUDFORMATION_HOME}/credential-file-path.template.
     Edit a copy of this file to add your information.
     On UNIX, limit permissions to the owner of the credential file: $ chmod 600 <the file created above>.
2. There are several ways to provide your credential information:
      a. Set the following environment variable: AWS_CREDENTIAL_FILE=<the file created in 1>
      b. Alternatively, provide the following option with every command --aws-credential-file <the file created in 1>
      c. Explicitly specify credentials on the command line: --I ACCESS_KEY --S SECRET_KEY
                                                                                                                                                             
Setting custom JVM properties
-----------------------------
                                                                                                                                                         
By setting the environment variable SERVICE_JVM_ARGS, you can pass arbitrary JVM properties to the command line.
For example, the following line sets proxy server properties in Linux/UNIX
 export SERVICE_JVM_ARGS="-Dhttp.proxyHost=http://my.proxy.com -Dhttp.proxyPort=8080"


Running:
---------

1. Check that your setup works properly, run the following command:
   $ cfn-cmd --help
      You should see the usage page for all AWS_CLOUDFORMATION commands

   $ cfn-describe-stacks --headers
      You should see a header line. If you have Stacks already created, you will see a description line for each Stack
