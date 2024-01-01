#!/bin/bash

#for repo in `mender-qa/integration/extra/release_tool.py -l docker`; do
#  mender-qa/integration/extra/release_tool.py --set-version-of $repo --version $1 --repository registry.gitlab.com/northern.tech/mender
#done

find mender-qa/integration -type f -iname 'docker-compose.*yml' -exec sed -i -r "s/(^\s*image:\s*)(mendersoftware|registry\.mender\.io)(\/mendersoftware\/|\/)(\S+):(\S+)$/\1registry.gitlab.com\/northern.tech\/mender\/\4\:master/" {} \; 
