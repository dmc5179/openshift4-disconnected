# env.sh

# Set the package manager
if [[ $(which dnf) ]]
then
    export PACKAGE_EXEC=$(which dnf)
elif [[ $(which microdnf) ]]
then
    export PACKAGE_EXEC=$(which microdnf)
elif [[ $(which yum) ]]
then
    export PACKAGE_EXEC=$(which yum)
else
    echo "RPM package manager not found"
    exit 1
fi
export PACKAGE_EXEC

# Set the pip version
if [[ $(which pip3) ]]
then
    export PIP_EXEC=$(which pip3)
elif [[ $(which pip) ]]
then
    export PIP_EXEC=$(which pip)
else
    echo "Pip not found"
    exit 1
fi
export PIP_EXEC
