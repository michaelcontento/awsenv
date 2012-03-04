Relational Data Service (RDS) Command Line Tools
================================================

Installation:
-------------
1. Ensure that JAVA version 1.5 or higher is installed on your system: (java -version)
2. Unzip the deployment zip file
3. Set the following environment variables:
3.1 AWS_RDS_HOME - The directory where the deployment files were copied to
        check with:
           Unix: ls ${AWS_RDS_HOME}/bin should list rds-describe-db-instances ...)
           Windows: dir %AWS_RDS_HOME%\bin should list rds-describe-db-instances ...)
3.2 JAVA_HOME - Java Installation home directory
4. Add ${AWS_RDS_HOME}/bin (in Windows: %AWS_RDS_HOME%\bin) to your path
5. (Unix only) Set execute permissions on all files in the bin directory: chmod +x ${AWS_RDS_HOME}/bin/*

Configuration:
--------------
Provide the command line tool with your AWS user credentials. There are two ways you can provide credentials: AWS keys, or using X.509 certificates.

Using AWS Keys
--------------
1. Create a credential file: The deployment includes a template file ${AWS_RDS_HOME}/credential-file-path.template. Edit a copy of this file to add your information.
     On UNIX, limit permissions to the owner of the credential file: $ chmod 600 <the file created above>.
2. There are several ways to provide your credential information:
      a. Set the following environment variable: AWS_CREDENTIAL_FILE=<the file created in 1>
      b. Alternatively, provide the following option with every command --aws-credential-file <the file created in 1>
      c. Explicitly specify credentials on the command line: --I ACCESS_KEY --S SECRET_KEY
      
Using X.509 Certs
-----------------
1. Save your cetificate and private keys to files: e.g. my-cert.pem and my-pk.pem.

2. There are two ways to provide the certificate information to the command line tool:
    a.  Set the following environment variables:
        EC2_CERT=/path/to/my-cert.pem
        EC2_PRIVATE_KEY=/path/to/my-pk.pem
    b.  Specify the files directly on command-line for every command:
        <command> --ec2-cert-file-path=/path/to/my-cert.pem --ec2-private-key-file-path=/path/to/my-pk.pem

Running:
---------
Check that your setup works properly, run the following command:
   $ rds --help
      You should see the usage page for all RDS commands.
   $ rds-describe-db-instances --headers
      If you have database instances already configured, you will see a header line followed by a description line for each database instance.
      If you do not have any database instances yet, the command should simply run with no error output.
