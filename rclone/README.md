# Rclone

## Documentation

- [Cold Archive - Getting started with Cold Archive](https://help.ovhcloud.com/csm/en-public-cloud-storage-cold-archive-getting-started?id=kb_article_view&sysparm_article=KB0047338)
- [Object Storage - Utiliser Object Storage avec Rclone](https://help.ovhcloud.com/csm/fr-public-cloud-storage-s3-rclone?id=kb_article_view&sysparm_article=KB0047465)

## Setup

1. Install AWS CLI: [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2. Setup:

```sh
mkdir -p ~/.aws/cli
touch ~/.aws/cli/alias
```

`~/.aws/cli/alias` file:

```conf
put-ovh-archive = s3api put-bucket-intelligent-tiering-configuration --id ovh-cold-archive --intelligent-tiering-configuration '{"Id": "ovh-cold-archive", "Status": "Enabled", "Tierings": [{"Days": 999,"AccessTier": "OVH_ARCHIVE"}]}' --bucket

put-ovh-restore = s3api put-bucket-intelligent-tiering-configuration --id ovh-cold-archive --intelligent-tiering-configuration '{"Id": "ovh-cold-archive", "Status": "Enabled", "Tierings": [{"Days": 999,"AccessTier": "OVH_RESTORE"}]}' --bucket

get-ovh-bucket-status = s3api get-bucket-intelligent-tiering-configuration --id ovh-cold-archive --bucket

delete-ovh-archive = s3api delete-bucket-intelligent-tiering-configuration --id ovh-cold-archive --bucket
```

`~/.aws/credentials` file:

```conf
[default]
aws_access_key_id = [REDACTED]
aws_secret_access_key = [REDACTED]
```

`~/.aws/config` file:

```conf
[default]
region = rbx-archive
endpoint_url = https://s3.rbx-archive.io.cloud.ovh.net
services = ovh-rbx-archive

[services ovh-rbx-archive]
s3 =
  endpoint_url = https://s3.rbx-archive.io.cloud.ovh.net/
  signature_version = s3v4
  # payload_signing_enabled = true
  # addressing_style = path
  # use_accelerate_endpoint = false
  # max_concurrent_requests = 10
  # max_queue_size = 1000
  # multipart_threshold = 64MB
  # multipart_chunksize = 16MB
  # disable_multithreading = false
  # force_path_style = true
  # use_ssl = true
  # content_sha256 = UNSIGNED-PAYLOAD
  # use_dualstack_endpoint = false
  # use_path_style = true

s3api =
endpoint_url = https://s3.rbx-archive.io.cloud.ovh.net/
```

3. Verify the configuration

```
aws s3 ls
```

4. Create a bucket

```
aws s3 mb s3://bucketname
```
