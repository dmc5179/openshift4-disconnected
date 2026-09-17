#!/bin/bash

export GOVC_URL='https://vcenter.dota-lab.iad.redhat.com/'
export GOVC_USERNAME='Administrator@vsphere.local'
export GOVC_PASSWORD='RedHat1!'
export GOVC_INSECURE='true'

govc sso.user.id Administrator

govc sso.user.create -R=RegularUser -f=Open -l=Shift -p 'RedHat123$%^' openshift
