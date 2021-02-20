1. Create Project on Google Cloud Console (check how to do that with gcloud cli)

PROJECT_NAME=danocp4

gcloud projects create ${PROJECT_NAME} --name="LTO vfarias OCP"
gcloud config set project ${PROJECT_NAME}


1. Login to gcloud
`gcloud auth login`

1. List billing Accounts
gcloud alpha billing accounts list

1. Link billing account with project
gcloud alpha billing accounts projects link danocp4 --billing-account=

1. Enable required API services

`
SERVICES="compute.googleapis.com  cloudapis.googleapis.com  cloudresourcemanager.googleapis.com  dns.googleapis.com  iamcredentials.googleapis.com  iam.googleapis.com  servicemanagement.googleapis.com  serviceusage.googleapis.com  storage-api.googleapis.com  storage-component.googleapis.com"
for service in ${SERVICES}; do
  echo "Enabling service ${service}..."
  gcloud services enable ${service}
done
`
1. Create a service account

`
gcloud iam service-accounts create ocp-admin \
    --description "OCP adminstrator service account" \
    --display-name "OCP service account"
`

gcloud iam service-accounts get-iam-policy ocp-admin@${PROJECT_NAME}.iam.gserviceaccount.com --format json > policy.json

1. Configure roles for sevice account
`
ROLES="roles/compute.admin roles/compute.networkAdmin  roles/compute.securityAdmin  roles/storage.admin  roles/iam.serviceAccountUser roles/iam.serviceAccountAdmin roles/compute.viewer  roles/storage.admin roles/dns.admin roles/iam.securityAdmin"
for role in ${ROLES}; do
  gcloud projects add-iam-policy-binding ${PROJECT_NAME} \
    --member serviceAccount:ocp-admin@${PROJECT_NAME}.iam.gserviceaccount.com \
    --role ${role}
done

gcloud iam service-accounts add-iam-policy-binding ocp-admin@${PROJECT_NAME}.iam.gserviceaccount.com --member='user:danclark@redhat.com' --role='roles/owner'
`

1. Create service account key
gcloud iam service-accounts keys create ./key.json \
  --iam-account ocp-admin@${PROJECT_NAME}.iam.gserviceaccount.com

1. Create install config file

`
./openshift-install create install-config --dir=./install
`

1. Edit install config if required

1. Deploy cluster

`./openshift-install create cluster --dir=./install --log-level=info`
