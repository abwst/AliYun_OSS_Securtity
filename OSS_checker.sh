#!/bin/bash

#
# First tool for testing Security of OSS buckets using aliyun console
# Tool is designed for testing purpose only!
# Created by wojciech@syrkiewicz.com
#


#
# Checking bucket ACL
# Saving output to result.log
#

o=$(aliyun oss ls)
buckets=$(echo "$o" | cut -d "/" -f 3 | tail -n+2 | head -n -2)
echo "List of buckets and assigned ACL :" > results.log
for bucket in $buckets; do
    echo " "
    echo "Checking bucket $bucket permissions :"
    echo "Bucket $bucket :" >> results.log
    aliyun oss stat oss://$bucket | grep -e ACL -e ExtranetEndpoint | tee -a results.log
    echo " " >> results.log

done

#
# Listing public buckets content
#

region=$(cat results.log | grep Extranet | head -1 |cut -d "-" -f 2-3 | cut -d "." -f 1)
echo "$region"

public=$(cat results.log | grep -B2 public-read | grep Bucket | cut -d " " -f 2)
for oss in $public; do
        echo "Bucket $oss is public! here is listed content :"
        aliyun oss ls oss://$oss --region $region | tee -a listedbucket.txt
done

#
# Create public accessible downland links
#

cat listedbucket.txt | cut -d "/" -f 3-30 > cache.txt
cache=$(cat cache.txt)
for result in $cache; do
        first=$(echo $result | cut -d "/" -f 1)
        second=$(echo $result | cut -d "/" -f 2-30)
        echo http://"$first".oss-$region.aliyuncs.com/$second
done

