#!/bin/bash
TF_ENV=$1
ACTION=$2
lcEnv=$(echo "${TF_ENV}" | tr '[:upper:]' '[:lower:]')



function usage 
{
	echo "Usage: $0 TF_ENV=[ PROD | PRE-PROD | QA ] Action [ CHECKOUT | RESTORE ]"
	echo "$0 PROD CHECKOUT"
	echo "Checkout TF State files for Prod"
	echo "$0 PROD RESTORE"
	echo "Restore TF State files for Prod"
}

function sanity_check 
{

	if [ -z "$(grep \"$lcEnv\" terraform.tfvars)" ]
	then		
		echo "Current Statefile is not this env : $TF_ENV"
		exit 500
	fi
}

function ensure_dir_is_clean
{

	if ! [[ -d "./state/$lcEnv/" ]]
	then
		echo "Env $lcEnv doesn't exist"
		exit 500
	fi

	if [ -e "statefile.tf" ]
	then
		echo "TF State seems to be already present"
		exit 500;
	fi
}

function execute
{		

	if [ "$ACTION" == "CHECKOUT" ]
	then		
		echo "Checking out $TF_ENV"
		ensure_dir_is_clean;
		cp "state/$lcEnv/statefile.tf" .
		cp "state/$lcEnv/terraform.tfvars" .
		cp "state/$lcEnv/terraform.tfstate" .terraform/terraform.tfstate


	elif [ "$ACTION" == "RESTORE" ]
	then	
		sanity_check;
		mv statefile.tf "state/$lcEnv/statefile.tf"
		mv terraform.tfvars "state/$lcEnv/terraform.tfvars"
		mv .terraform/terraform.tfstate "state/$lcEnv/terraform.tfstate"
	else
		echo "Action: $ACTION Doesn't exist" 
	fi	

}


if (( $# < 2 ))
then
	usage
	exit
else
	execute $TF_ENV $ACTION
fi



