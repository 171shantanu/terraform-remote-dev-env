If you are going to use this template to run the TF Scripts. You will need to config the user SSH credentials in the 'ssh-config' file.
I have not uploaded the terraform providers directory as it was too large in size. Please make sure you are installing the required providers before applying the scripts by running 'terraform init' command.
You will need to add the public key or the path to the public key in the 'tf_auth' resource in the 'main.tf' file which will be used to authenticate the key file.
You will need to add the path to the key file which will be used to login through the local exec provisioner which is mentioned in the 'main.tf' file. 
You will need to specify the key name that you will you in 'dev_node' resource in the 'main.tf'