# SFTP <-> Azure Blob Storage Proxy

Since Azure Blob Storage does not provide a way to upload and download files over SFTP or FTP to the Blob Storage. This image helps us bridge the gap. This image mounts the Azure Blob Storage Container to a predefined path on the container and allows sftp access to the container.

It uses [BlobFuse](https://github.com/Azure/azure-storage-fuse) to mount the drive on the container and then exposes it over SFTP to the clients needing SFTP to the blob storage.

## Build Image

To build the image simply run the build command.

```bash
docker build -t <tag> .
```

## Environment Variables


Here are some of the environment variables that are required for the image to work as intended.

| Key           | Description                                           | Default     | Required |
| ------------- | ----------------------------------------------------- | ----------- | -------- |
| STORAGE_DRIVE | Location where the azure blob storage will be mounted | /mnt/store/ | true     |
| SFTP_USER     | Username to use for the SFTP user                     | user        | true     |
| SFTP_PASS     | Password to use for the SFTP user                     | pass        | true     |
| SFTP_UID      | User ID for the $SFTP_USER user                       | 1000        | false    |
| SFTP_GID      | Group ID for the $SFTP_USER user group                | 1000        | false    |
| SFTP_PORT     | Port to Expose and configure SFTP/SSH server on       | 22          | false    |


### Azure Blob Storage

There are numerous ways we can authenticate with blob storage to mount. Below are some environment varibales to configure connection to blob storage.

General Options (required for all authentication types):

| Key                          | Description                                        | Default | Required |
| ---------------------------- | -------------------------------------------------- | ------- | -------- |
| AZURE_STORAGE_CONTAINER_NAME | Azure Container Name                               |         | true     |
| AZURE_STORAGE_ACCOUNT        | Azure Storage Account Name                         |         | true     |
| AZURE_STORAGE_AUTH_TYPE      | Type of authentication to use (Key, SAS, MSI, SPN) | Key     | false    |


When `AZURE_STORAGE_AUTH_TYPE` is `Key`

| Key                      | Description                                                  | Default |
| ------------------------ | ------------------------------------------------------------ | ------- |
| AZURE_STORAGE_ACCESS_KEY | Specifies the storage account key to use for authentication. |         |

When `AZURE_STORAGE_AUTH_TYPE` is `SAS`

| Key                     | Description                                        | Default |
| ----------------------- | -------------------------------------------------- | ------- |
| AZURE_STORAGE_SAS_TOKEN | Specifies the SAS token to use for authentication. |         |

When `AZURE_STORAGE_AUTH_TYPE` is `MSI`

| Key                                | Description | Default |
| ---------------------------------- | ----------- | ------- |
| AZURE_STORAGE_IDENTITY_CLIENT_ID   |             |         |
| AZURE_STORAGE_IDENTITY_OBJECT_ID   |             |         |
| AZURE_STORAGE_IDENTITY_RESOURCE_ID |             |         |
| MSI_ENDPOINT                       |             |         |
| MSI_SECRET                         |             |         |

When `AZURE_STORAGE_AUTH_TYPE` is `SPN`

| Key                             | Description                                                    | Default |
| ------------------------------- | -------------------------------------------------------------- | ------- |
| AZURE_STORAGE_SPN_CLIENT_ID     | Specifies the client ID for your application registration      |         |
| AZURE_STORAGE_SPN_TENANT_ID     | Specifies the tenant ID for your application registration      |         |
| AZURE_STORAGE_AAD_ENDPOINT      | Specifies a custom AAD endpoint to authenticate against        |         |
| AZURE_STORAGE_SPN_CLIENT_SECRET | Specifies the client secret for your application registration. |         |


## Running the Container

Below is an example of how you would run a container with default SSH user. We will authenticate with Storage Account using Access Key.

```bash
docker run -dit --privileged -p 1234:22 --name test \
  -e AZURE_STORAGE_ACCOUNT="storage_account" \
  -e AZURE_STORAGE_ACCESS_KEY="access_key" \
  -e AZURE_STORAGE_CONTAINER_NAME="container_name" \
  -e SFTP_USER="user"
  -e SFTP_PASS="password"
  ani1797/blob-proxy:1.1

# User Information: user is 'user' and password is 'password'

# Login to SSH using the default user
ssh user@localhost -p 1234

# Access Blob Storage using SFTP
sftp -oPort=1234 user@localhost

# issuing ls will show all files from blob storage
sftp> ls
sftp> quit
```
