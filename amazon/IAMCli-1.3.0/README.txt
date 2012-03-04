AWS Identity and Access Management (IAM) Command Line Tools
===========================================================

Installation:
-------------

1. Ensure that Java version 1.6 is installed on your system: (java -version)

2. Unzip the deployment zip file

3. Set the following environment variables:
  3.1 AWS_IAM_HOME - The directory where the zip file is extracted to
        check with:
           Unix: ls ${AWS_IAM_HOME} should list README.txt, etc
           Windows: dir %AWS_IAM_HOME% should list README.txt, etc
  3.2 JAVA_HOME - Java Installation home directory

4. Add ${AWS_IAM_HOME}/bin (in Windows: %AWS_IAM_HOME%\bin) to your path

Configuration:
--------------

Provide the command line tool with your AWS user credentials and your client
configurations.

(a) AWS Credentials
-------------------

1. Create a credential file: The deployment includes a template file
   ${AWS_IAM_HOME}/aws-credential.template. Edit a copy of this file to add
   your information.  On UNIX, limit permissions to the owner of the credential
   file: $ chmod 600 <the file created above>.

2. There are two ways to provide your credential information:
      a. Set the following environment variable: AWS_CREDENTIAL_FILE=<the file
         created in 1>

      b. Alternatively, provide the following option with every command
         --aws-credential-file <the file created in 1>

(b) Client Configurations (Proxy settings, etc)
-----------------------------------------------

1. Create a client configuration file: The deployment includes a template file
   ${AWS_IAM_HOME}/client-config.template. Edit a copy of this file to add
   your configurations.

2. There are two ways to provide your client configurations to the CLI:
      a. Set the following environment variable: CLIENT_CONFIG_FILE=<the file
         created in 1>

      b. Alternatively, provide the following option with every command
         --client-config-file <the file created in 1>

Running:
--------

Check that your setup works properly, run the following command:
   $ iam-userlistbypath
The command should simply run with no error output.
