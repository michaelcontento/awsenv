SNS Command Line Tools
===============================

Installation:
-------------

1. Ensure that JAVA version 1.6 or higher is installed on your system: (java -version)
2. Unzip the deployment zip file
3. Set the following environment variables:
3.1 AWS_SNS_HOME - The directory where the deployment files were copied to
        check with:
           Unix: ls ${AWS_SNS_HOME}/bin should list sns-cmd...)
           Windows: dir "%AWS_SNS_HOME%\bin" should list sns-cmd ...)
3.2 JAVA_HOME - Java Installation home directory
4. Add ${AWS_SNS_HOME}/bin (in Windows: "%AWS_SNS_HOME%\bin") to your path

Configuration:
--------------

Provide the command line tool with your AWS Keys:

1. Create a credential file: The deployment includes a template file ${AWS_SNS_HOME}/credential-file-path.template.
     Edit a copy of this file to add your information.
     On UNIX, limit permissions to the owner of the credential file: $ chmod 600 <the file created above>.
2. There are several ways to provide your credential information:
      a. Set the following environment variable: AWS_CREDENTIAL_FILE=<the file created in 1>
      b. Alternatively, provide the following option with every command --aws-credential-file <the file created in 1>
      c. Explicitly specify credentials on the command line: --I ACCESS_KEY --S SECRET_KEY

Running:
---------

1. To check that your setup works properly, run the following command:
   $ sns-cmd --help
      You should see the usage page for all SNS commands

   $ sns-list-topics --headers
      You should see a header line. If you have topics
      already created, you will see their names




