import boto3

AWS_PROFILE = "covid"
SITE_BASE_URL = "http://raytest.rs.ring.com.s3-website-us-east-1.amazonaws.com"
SITE_BUCKET_NAME = "raytest.rs.ring.com"
LATEST_PREFIX = "v0/snap/latest/"
SOURCE_DIR = "v0/snap/04012020/"
session = boto3.session.Session(profile_name=AWS_PROFILE)


#
# Todo: fix the file extenstion filter to match what we want
#
def populate_latest(source_dir):
    print("populate_latest >>>>")
    s3 = session.resource('s3')
    site_bucket = s3.Bucket(SITE_BUCKET_NAME)
    for object_summary in site_bucket.objects.filter(Prefix=source_dir, Delimiter="/"):
        if object_summary.key.endswith("html"):
            desturl = SITE_BASE_URL + "/" + object_summary.key
            destfile = object_summary.key
            destobj = s3.Object(SITE_BUCKET_NAME, destfile)
            print(destobj.content_type)
            latestfile = LATEST_PREFIX + destfile.split("/")[-1]
            print("\tLast File: " + latestfile + "  Linked to: " + destfile)
            # symlink = s3.Object(BUCKET_NAME, latestfile).put(Body=destobj.get()['Body'].read(),
            symlink = s3.Object(SITE_BUCKET_NAME, latestfile).put \
                (Body="latest",
                 ContentType=destobj.content_type,
                 WebsiteRedirectLocation=desturl
                 # Metadata={'x-amz-website-redirect-location': desturl, }
                 )

# Create symlinks in s3://link_bucket/link_prefix to the files in s3://src_bucket/src_prefix
def create_symlinks(s3_symlink_bucket, s3_symlink_prefix, s3_src_bucket, s3_src_prefix, site_base_url):
    print("create_symlinks >>>>")
    s3=session.resource('s3')
    #symlink_bucket = s3.Bucket(s3_link_bucketlink_bucket)
    source_bucket = s3.Bucket(s3_src_bucket)

    # iterate through the objects in the source bucket and create symlinks in the link bucket
    for source_object_summary in source_bucket.objects.filter(Prefix=s3_src_prefix, Delimiter="/"):

        # TODO - fix for actual objects we want to link (e.g. json)
        if source_object_summary.key.endswith("html"):

            source_object = s3.Object(s3_src_bucket,source_object_summary.key)
            symlink_url = site_base_url + "/" + source_object_summary.key
            symlink_filename = source_object_summary.key.split("/")[-1]
            print("Linking: " + s3_symlink_bucket + "/" + s3_symlink_prefix + symlink_filename +
                  " to: " + symlink_url)

            #now, create a dummy text file in s3_link_bucket with a URL redirect to the web path to actual data
            s3.Object(s3_symlink_bucket, s3_symlink_prefix + symlink_filename).put \
                (Body="symlink: ",
                 ContentType=source_object.content_type,
                 WebsiteRedirectLocation=symlink_url
                 )

#
#
#
def delete_s3_contents(bucket, prefix):
    print("delete_latest: >>>>")
    s3 = session.resource('s3')
    site_bucket = s3.Bucket(bucket)
    site_bucket.objects.filter(Prefix=prefix).delete()

 #
 #   List the contents of a bucket and prefix (e.g. folder path)
 #   list_s3("my-super-bucket","folder/magic/")
def list_s3(bucket, prefix):
    print("dump_latest: >>>>")
    s3 = session.resource('s3')
    site_bucket = s3.Bucket(bucket)
    for object_summary in site_bucket.objects.filter(Prefix=prefix, Delimiter="/"):
        print("\t" + object_summary.key)


def sample_usage():
    # List the contents of the bucket with the latest data
    list_s3(SITE_BUCKET_NAME, LATEST_PREFIX)

    # purge the contents of the bucket with the latest data
    # TODO - how to do this in a non interrupting manner
    delete_s3_contents(SITE_BUCKET_NAME, LATEST_PREFIX)

    # List the contents again so we see it is gone
    list_s3(SITE_BUCKET_NAME, LATEST_PREFIX)

    #populate_latest(SOURCE_DIR)
    create_symlinks(SITE_BUCKET_NAME,LATEST_PREFIX,
                    SITE_BUCKET_NAME,SOURCE_DIR,SITE_BASE_URL)

    # Look new files :-)
    list_s3(SITE_BUCKET_NAME, LATEST_PREFIX)


#
# Todo - add function to validate with curl
#

if __name__ == '__main__':
    sample_usage()
