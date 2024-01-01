#!/bin/bash

#for repo in `mender-qa/integration/extra/release_tool.py -l docker`; do
#  mender-qa/integration/extra/release_tool.py --set-version-of $repo --version $1 --repository registry.gitlab.com/northern.tech/mender
#done

find mender-qa/integration \
  -type f \
  -iname 'docker-compose.*yml' \
  -exec \
    sed \
      --in-place \
      --regexp-extended "s/(^\s*image:\s*)(mendersoftware|registry\.mender\.io)(\/mendersoftware\/|\/)(\S+):(\S+)$/\1registry.gitlab.com\/northern.tech\/mender\/\4\:master/" {} \; 

# restore previous mender-test-container image
find mender-qa/integration \
  -type f \
  -iname 'docker-compose.*yml' \
  -exec \
    sed \
      --in-place \
      --regexp-extended "s/(^\s*image:\s*)(registry\.gitlab\.com\/northern\.tech\/mender\/mender-test-containers:\S+)$/\1mendersoftware\/mender-test-containers:backend-integration-testing/" {} \; 

# fix workflows registry
find mender-qa/integration \
  -type f \
  -iname 'docker-compose.*yml' \
  -exec \
    sed \
      --in-place \
      --regexp-extended "s/(^\s*image:\s*)(registry\.gitlab\.com)(\/northern\.tech\/mender\/)(workflows-worker):(\S+)$/\1\2\3workflows:\5/" {} \; 


find mender-qa/integration \
  -type f \
  -iname 'docker-compose.*yml' \
  -exec \
    grep 'image:' {} \;
