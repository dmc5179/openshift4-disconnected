# Cross Account Route53 Private Hosted Zone access

## Authorize the association (Account A):

- The owner of the PHZ must authorize the VPC in Account B to associate with it.

```console
aws route53 create-vpc-association-authorization --hosted-zone-id <Zone-ID> --vpc VPCRegion=<Region>,VPCId=<VPC-ID-from-Account-B>
```

## Associate the VPC (Account B):

- Run this command from Account B to complete the link.

```console
aws route53 associate-vpc-with-hosted-zone --hosted-zone-id <Zone-ID-from-Account-A> --vpc VPCRegion=<Region>,VPCId=<VPC-ID>
```

## Delete the authorization (Account A - Optional but recommended):

- After the association is established, you should remove the authorization for security best practices.

```console
aws route53 delete-vpc-association-authorization --hosted-zone-id <Zone-ID> --vpc VPCRegion=<Region>,VPCId=<VPC-ID-from-Account-B>
```

## Notes and other options

- VPC DNS Settings: Both enableDnsHostnames and enableDnsSupport must be set to true in the VPC settings for the records to resolve.

- Listing Records: Once associated, you can view the records using the aws route53 list-resource-record-sets command with the remote Hosted Zone ID.

- Alternative (Route 53 Profiles): For large organizations, you can use Route 53 Profiles to manage and share PHZ associations across multiple accounts more easily.
https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-test.html
