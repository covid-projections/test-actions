import boto3

AWS_PROFILE = "covid"
BASE_URL = "http://raytest.rs.ring.com.s3-website-us-east-1.amazonaws.com"
BUCKET_NAME = "raytest.rs.ring.com"
LATEST_PREFIX = "v0/snap/latest/"
SOURCE_DIR = "v0/snap/04062020/"
session = boto3.session.Session(profile_name=AWS_PROFILE)


#
# Todo: fix the file extenstion filter to match what we want
#
def populate_latest(source_dir):
    print("populate_latest >>>>")
    s3 = session.resource('s3')
    site_bucket = s3.Bucket(BUCKET_NAME)
    for object_summary in site_bucket.objects.filter(Prefix=source_dir, Delimiter="/"):
        if object_summary.key.endswith("html"):
            desturl = BASE_URL + "/" + object_summary.key
            destfile = object_summary.key
            destobj = s3.Object(BUCKET_NAME, destfile)
            print(destobj.content_type)
            latestfile = LATEST_PREFIX + destfile.split("/")[-1]
            print("\tLast File: " + latestfile + "  Linked to: " + destfile)
            # symlink = s3.Object(BUCKET_NAME, latestfile).put(Body=destobj.get()['Body'].read(),
            symlink = s3.Object(BUCKET_NAME, latestfile).put \
                (Body="latest",
                 ContentType=destobj.content_type,
                 WebsiteRedirectLocation=desturl
                 #Metadata={'x-amz-website-redirect-location': desturl, }
                 )


def delete_latest():
    print("delete_latest: >>>>")
    s3 = session.resource('s3')
    site_bucket = s3.Bucket(BUCKET_NAME)
    site_bucket.objects.filter(Prefix=LATEST_PREFIX).delete()


def dump_latest():
    print("dump_latest: >>>>")
    s3 = session.resource('s3')
    site_bucket = s3.Bucket(BUCKET_NAME)
    for object_summary in site_bucket.objects.filter(Prefix=LATEST_PREFIX, Delimiter="/"):
        print("\t" + object_summary.key)


#
# Todo - add function to validate with curl
#

if __name__ == '__main__':
    dump_latest()
    delete_latest()
    dump_latest()
    populate_latest(SOURCE_DIR)
    dump_latest()
