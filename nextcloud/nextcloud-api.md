# Nextcloud API 
 
## File Manipulation using http/1.1 request
**Assume FileDrop/Shared Folder url is**  
> `https://drive.dev.sql.com.my/s/qBHMPg9JSaWJBrX`

### Upload to FileDrop/Shared Folder using http request (Require folder id from share link as username)
*If the link is **password protected**, include the password in basic auth (-u username:password).*
```shell
curl -T files.txt -u "qBHMPg9JSaWJBrX:" -H "X-Requested-With:XMLHttpRequest" https://drive.dev.sql.com.my/public.php/webdav/
```

### Retrieve file list (require folder id from share link and base64encode)
> cUJITVBnOUpTYVdKQnJYOnBhc3N3b3Jk = base64encode(qBHMPg9JSaWJBrX:)
```shell
curl -X PROPFIND -H "Authorization: Basic cUJITVBnOUpTYVdKQnJYOnBhc3N3b3Jk" -H "X-Requested-With:XMLHttpRequest" https://drive.dev.sql.com.my/public.php/webdav/
```

### Download from Shared Folder using http request (require filename and share link)
```shell
curl https://drive.dev.sql.com.my/s/qBHMPg9JSaWJBrX/download?path=/filename -o filename
```

### Delete a file in Shared Folder 
```shell
curl -XDELETE -u "qBHMPg9JSaWJBrX:" -H "X-Requested-With-XMLHttpRequest" https://drive.dev.sql.com.my/public.php/webdav/test/load-balancer-example.yaml
```

### Move a file in Shared Folder
```shell
curl -XMOVE -u "qBHMPg9JSaWJBrX:" -H "X-Requested-With:XMLHttpRequest" -H "destination:https://drive.dev.sql.com.my/public.php/webdav/test/files.txt" https://drive.dev.sql.com.my/public.php/webdav/files.txt
```

---
## Webdav API
## Testing with curl
```shell
curl -X PROPFIND -u changsheng:password 'https://drive.dev.sql.com.my/remote.php/dav/files/changsheng' -d 
'<?xml version="1.0"?>
<d:propfind  xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns">
  <d:prop>
        <d:getlastmodified />
        <d:getetag />
        <d:getcontenttype />
        <d:resourcetype />
        <oc:fileid />
        <oc:permissions />
        <oc:size />
        <d:getcontentlength />
        <nc:has-preview />
        <oc:favorite />
        <oc:comments-unread />
        <oc:owner-display-name />
        <oc:share-types />
  </d:prop>
</d:propfind>'
```

###
## Upload
```shell
curl -X PUT -u changsheng:password 'https://drive.dev.sql.com.my/remote.php/dav/files/changsheng/photos.xml' --data-binary '@photos.xml'
```
**Response Headers:**
```
HTTP/1.1 201 Created
Server: nginx
Date: Wed, 09 Oct 2019 03:20:33 GMT
Content-Type: text/html; charset=UTF-8
Content-Length: 0
Connection: close
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate
Pragma: no-cache
Content-Security-Policy: default-src 'none';
OC-FileId: 00014134ocavo5k17gb5
ETag: "fa21984e203eb3b76f6f6c88a12cbce6"
OC-ETag: "fa21984e203eb3b76f6f6c88a12cbce6"
```
---
## OCS API 
**Append `format=json` in the url to get response in JSON format.**

###
## Generate direct download url for `fileId`
> Link only valid for 24 hours
```shell
curl -u changsheng-microsoft:password -X POST 'https://drive.dev.sql.com.my/ocs/v2.php/apps/dav/api/v1/direct' -H "OCS-APIRequest: true" -d 
'fileId=738'
```

###
## Get user metadata
```shell
curl -u changsheng:password 'https://drive.dev.sql.com.my/ocs/v1.php/cloud/users/changsheng' -H "OCS-APIRequest: true"
```

###
## Create User
```shell
curl -u changsheng:password -X POST 'https://drive.dev.sql.com.my/ocs/v1.php/cloud/users' -H "OCS-APIRequest: true" -d 
"userid=testuser01&password=password&displayName=TestUser01"
```
###
## Create New Share
```shell
curl -u changsheng:password 'https://drive.dev.sql.com.my/ocs/v2.php/apps/files_sharing/api/v1/shares?format=json' -d 
'path=/Upload/599.png&shareType=3&permissions=1' -H "OCS-APIRequest: true"
```
---

## Reference
1. [Nextcloud user provisioning API](https://docs.nextcloud.com/server/latest/admin_manual/configuration_user/user_provisioning_api.html)
2. [Nextcloud Webdav API](https://docs.nextcloud.com/server/latest/developer_manual/client_apis/WebDAV/index.html)
3. [Nextcloud OCS API](https://docs.nextcloud.com/server/latest/developer_manual/client_apis/OCS/index.html#)