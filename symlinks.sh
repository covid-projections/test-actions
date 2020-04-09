#set -x

# todo - add confirmation curls to each change to validate
# todo need to fill in default rules if none are present?  Test this

#
# CONFIG - CHANGE AS NEEDED
#
AWS_CLI_BASE_CMD="aws --profile covid"
BUCKET=raytest.rs.ring.com
OUTFILE="/tmp/routing%%.json"

######################################
# This script tells S3 websites to redirect one path to another
#
# Sample usage
#
# ./symlinks.sh -s "v0/snap/foo" -d "v0/snap/latest" [-practice]
#
######################################

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

# Pull existing configuration
current_config_file=/tmp/current-config$$.json
$AWS_CLI_BASE_CMD s3api get-bucket-website --bucket $BUCKET >| $current_config_file
current_config=$(<$current_config_file)

#echo $current_config | jq '.'
i=0
matched="no"
for row in $(echo $current_config | jq '.RoutingRules[].Condition.KeyPrefixEquals');do
    #echo ${row} | jq -r '.[]'
    #echo $row
    if [ "$row" == "$PATH_TO_REDIRECT" ]; then
        echo "Rule already exists, updating..."
        #todo - should check value and don't do anything if they already match
        new_config=$(echo $current_config | jq '.RoutingRules['$i'].Redirect.ReplaceKeyPrefixWith = '$REDIRECT_DESTINATION'')
        matched="yes"
    fi
    i=$(expr $i + 1)
done

if [ "$matched" == "no" ]; then
    echo "New rule"
    new_config=$(echo $current_config | jq '.RoutingRules['$i'].Condition |= . + {"KeyPrefixEquals":'$PATH_TO_REDIRECT'}')
    new_config=$(echo $new_config | jq '.RoutingRules['$i'].Redirect |= . + {"ReplaceKeyPrefixWith":'$REDIRECT_DESTINATION'}')
fi

echo $new_config >| $OUTFILE

#
# If practice mode, display results and exit w/out modifying S3
#
if [ "$PRACTICE" == "yes" ]; then
    cat $OUTFILE | jq -r
    echo "No changes applied to S3"
    exit 0
fi

#
# Write the new configuration
#
$AWS_CLI_BASE_CMD s3api put-bucket-website --bucket $BUCKET --website-configuration file://$OUTFILE

if [ $? != 0 ]; then
    echo "Error setting up symlinks"
fi

exit $?




