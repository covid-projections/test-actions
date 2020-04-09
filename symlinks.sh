#set -x


# todo - add confirmation curls to each change to validate
# todo need to fill in default rules if none are present?  Test this
# todo ensure this is re-entrant for multiple mapping calls

#
# CONFIG - CHANGE AS NEEDED
#
AWS_CLI_BASE_CMD="aws --profile covid"
BUCKET=raytest.rs.ring.com




#DEFAULT_ROUTING_RULES="{\"IndexDocument\":{\"Suffix\":\"index.html\"},\"RoutingRules\":[{\"Condition\":{\"KeyPrefixEquals\":\"placeholdernotreal\"},\"Redirect\":{\"ReplaceKeyPrefixWith\":\"obsolete\"}}]}"
OUTFILE="/tmp/routing%%.json"


#
# This script tells S3 websites to redirect one path to another
#
# Sample usage
#
# ./symlinks.sh -s "v0/snap/foo" -d "v0/snap/latest"
# curl http://raytest.rs.ring.com.s3-website-us-east-1.amazonaws.com/v0/snap/foo/ --verbose


###
# Main script
#
#
# arg parsing from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--sourcepath)
    PATH_TO_REDIRECT="\"$2\""
    shift # past argument
    shift # past value
    ;;
    -d|--destinationpath)
    REDIRECT_DESTINATION="\"$2\""
    shift # past argument
    shift # past value
    ;;
    -practice)
    PRACTICE="yes"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "Setting routing redirects: mapping $PATH_TO_REDIRECT to $REDIRECT_DESTINATION"


current_config_file=/tmp/current-config$$.json
$AWS_CLI_BASE_CMD s3api get-bucket-website --bucket $BUCKET >| $current_config_file
current_config=$(<$current_config_file)
new_config=""


#echo $current_config | jq '.'
i=0
for row in $(echo $current_config | jq '.RoutingRules[].Condition.KeyPrefixEquals');do
    #echo ${row} | jq -r '.[]'
    #echo $row
    if [ "$row" == "$PATH_TO_REDIRECT" ]; then
        echo "Rule already exists, updating..."
        #todo - should check value and don't do anything if they already match
        new_config=$(echo $current_config | jq '.RoutingRules['$i'].Redirect.ReplaceKeyPrefixWith = '$REDIRECT_DESTINATION'')
    else
        echo "New rule!!"
    fi
    i=$(expr $i + 1)
done

echo $new_config >| $OUTFILE


if [ "$PRACTICE" == "yes" ]; then
    cat $OUTFILE | jq -r
    echo "No changes applied to S3"
    exit 0
fi
#$AWS_CLI_BASE_CMD s3api put-bucket-website --bucket raytest.rs.ring.com --website-configuration file://$$.json
#json_output="{\"IndexDocument\":{\"Suffix\":\"index.html\"},\"RoutingRules\":[{\"Condition\":{\"KeyPrefixEquals\":$PATH_TO_REDIRECT},\"Redirect\":{\"ReplaceKeyPrefixWith\":$REDIRECT_DESTINATION}}]}"
#echo $json_output >| $$.json

$AWS_CLI_BASE_CMD s3api put-bucket-website --bucket $BUCKET --website-configuration file://$OUTFILE

if [ $? != 0 ]; then
    echo "Error setting up symlinks"
fi

exit $?




