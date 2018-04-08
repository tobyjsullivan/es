# ES (Encrypted S3 Store)

The objective of this project is to provide a simple command line tool for
storing data securely on S3. Content should be encrypted both in transit and in
storage (S3).

## Prerequisites

The following software must be installed to run.

* `terraform`
* `aws` cli with credentials configured in `~/.aws/`
* `openssl`

## Design

### User Experience

#### Help

```
./bin/es help [command]
```

#### Init

This command initializes the data store. Type `yes` to build S3 infrastructure when prompted by terraform.

```sh
./bin/es init --state-bucket <bucket-name> --state-key <key-path> [--state-region <region>] --storage-bucket <bucket-name> [--storage-region <region>]
```

Options:
* `--tfstate-bucket` The S3 bucket to store terraform state in.
* `--tfstate-key` The S3 key of the terraform state file.
* `--tfstate-region` The S3 region of the terraform state file. (Default: us-east-1)
* `--storage-bucket` The name to use for the S3 bucket for storing encrypted data.
* `--storage-region` The region of the S3 bucket for storing encrypted data. (Default: us-east-1)

Example:

```sh
./bin/es init --state-bucket "terraform-states.mydomain.example" --state-key "states/es.terraform.tfstate" --storage-bucket "encrypted-store.mydomain.example"
```

#### Add a Document

This command adds the document to storage.

```sh
./bin/es add <local-file-path>
```

#### List documents

This command lists the documents in storage.

```sh
./bin/es ls
```

#### Get a document

This command retrieves a document from storage and decrypts it on local disk.

```sh
./bin/es get <document-key> <output-file>
```

### Security

* Content is encrypted in transit and in storage.
* Any metadata about content (such as filenames) is also be encrypted in
  transit and in storage.

### Architecture

* Data is stored on S3 encrypted with keys managed by KMS.
   * Each document is encrypted with a unique data key.
   * The data key is stored alongside the blob and is encrypted with a master key
     managed by KMS. This is following best practices of KMS.
   * Each encrypted document is stored on S3 with at a randomly generated path.
     These paths are used as a claimscheck identifier in the mapping file.
* Metadata about documents is stored in a single, encrypted mapping file on S3.
   * This includes descriptors such as human-friendly key, the actual S3 key of the
     blob, and the S3 key of the encrypted data key.
   * The mapping file is stored the same as any other document. Encrypted with a
     co-located data key. However, the filenames for the mapping document and its key
     must be deterministic (i.e., non-random) so that they can be found without any
     other prerequisite knowledge.
