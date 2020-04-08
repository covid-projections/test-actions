#set -x


#
# This script tells S3 websites to redirect one path to another
#
# Sample usage
#
# ./symlinks.sh -s "v0/snap/foo" -d "v0/snap/latest"
# curl http://raytest.rs.ring.com.s3-website-us-east-1.amazonaws.com/v0/snap/foo/ --verbose




#reference_configuration_json="{\"IndexDocument\":{\"Suffix\":\"index.html\"},\"RoutingRules\":[{\"Condition\":{\"KeyPrefixEquals\":\"v0\/snap\/stable\/\"},\"Redirect\":{\"ReplaceKeyPrefixWith\":\"v0\/snap\/itworks\/\"}}]}"
#testme="{\"IndexDocument\":{\"Suffix\":\"index.html\"},\"RoutingRules\":[{\"Condition\":{\"KeyPrefixEquals\":\"v0\/snap\/stable\/\"},\"Redirect\":{\"ReplaceKeyPrefixWith\":$redirect_dest}}]}"
#path_to_redirect="\"v0\/snap\/stable\/\""
#redirect_dest="\"v0\/snap\/itworks\/\""



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
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "Setting routing redirects: mapping $PATH_TO_REDIRECT to $REDIRECT_DESTINATION"

json_output="{\"IndexDocument\":{\"Suffix\":\"index.html\"},\"RoutingRules\":[{\"Condition\":{\"KeyPrefixEquals\":$PATH_TO_REDIRECT},\"Redirect\":{\"ReplaceKeyPrefixWith\":$REDIRECT_DESTINATION}}]}"
echo $json_output >| $$.json

aws --profile covid s3api put-bucket-website --bucket raytest.rs.ring.com --website-configuration file://$$.json

if [ $? != 0 ]; then
    echo "Error setting up symlinks"
fi

exit $?




