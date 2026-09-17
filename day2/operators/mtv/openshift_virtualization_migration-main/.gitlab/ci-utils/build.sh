#!/bin/bash -eu

SEMVER_EXTRA_ASSETS=(
  roles
  playbooks
  README.md
  galaxy.yml
  changelogs
  CHANGELOG.rst
)

PYTHON_DEPENDENCIES="distlib antsibull-changelog"

for dir in $(ls -d roles/*); do
  echo "Running docsible role generation against ${dir}"
  if [ -f ${dir}/docsible-role-template.md ]; then
    DOCSIBLE_TEMPLATE="${dir}/docsible-role-template.md"
  else
    DOCSIBLE_TEMPLATE="./.gitlab/ci-utils/docsible-role-template.md"
  fi
  docsible --md-template ${DOCSIBLE_TEMPLATE} \
    --role ${dir} --no-backup --append | tee -a collection-build.log
  git add ${dir}/README.md
done

# Install extra python dependencies if defined
if [ -n "${PYTHON_DEPENDENCIES}" ]; then
  # Set the pip version
  if [[ $(which pip3) ]]; then
      export PIP_EXEC=$(which pip3)
  elif [[ $(which pip) ]]; then
      export PIP_EXEC=$(which pip)
  else
      echo "Pip not found"
      exit 1
  fi
  $PIP_EXEC install ${PYTHON_DEPENDENCIES}
fi

# Run antsibull-changelog release to update changelog and delete fragments
antsibull-changelog release | tee -a collection-build.log

for i in "${SEMVER_EXTRA_ASSETS[@]}"; do
  git add "$i" | tee -a collection-build.log
done

ansible-galaxy collection build . | tee -a collection-build.log
