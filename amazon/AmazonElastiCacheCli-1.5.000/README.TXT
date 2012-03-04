(Amazon ElastiCache) Command Line Tools
================================================

Installation:
-------------
1. Ensure that JAVA version 1.5 or higher is installed on your system: (java -version)
2. Unzip the deployment zip file
3. Set the following environment variables:
3.1 AWS_ELASTICACHE_HOME - The directory where the deployment files were copied to
        check with:
           Unix: ls ${AWS_ELASTICACHE_HOME}/bin should list elasticache-describe-cache-clusters ...)
           Windows: dir %AWS_ELASTICACHE_HOME%\bin should list elasticache-describe-cache-clusters ...)
3.2 JAVA_HOME - Java Installation home directory
4. Add ${AWS_ELASTICACHE_HOME}/bin (in Windows: %AWS_ELASTICACHE_HOME%\bin) to your path
5. (Unix only) Set execute permissions on all files in the bin directory: chmod +x ${AWS_ELASTICACHE_HOME}/bin/*

Configuration:
--------------
Provide the command line tool with your AWS user credentials
1. Create a credential file: The deployment includes a template file ${AWS_ELASTICACHE_HOME}/credential-file-path.template. Edit a copy of this file to add your information.
     On UNIX, limit permissions to the owner of the credential file: $ chmod 600 <the file created above>.
2. There are several ways to provide your credential information:
      a. Set the following environment variable: AWS_CREDENTIAL_FILE=<the file created in 1>
      b. Alternatively, provide the following option with every command --aws-credential-file <the file created in 1>
      c. Explicitly specify credentials on the command line: --I ACCESS_KEY --S SECRET_KEY
      
Running:
---------
Check that your setup works properly, run the following command:
   $ elasticache --help
      You should see the usage page for all AmazonElastiCache commands.
   $ elasticache-describe-cache-clusters --headers
      If you have cache clusters already configured, you will see a header line followed by a description line for each cache cluster.
      If you do not have any cache cluster yet, the command should simply run with no error output.
