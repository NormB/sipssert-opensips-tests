#!/bin/sh
# Build the OpenSIPS image for the NATS sets from an OpenSIPS source tree.
#
#   nats-image/build.sh <opensips-tree> [tag]
#
# The tree's committed HEAD is archived (git archive), so local edits are
# not built.  CPUS=<list> pins the build to those CPUs (docker's legacy
# builder, --cpuset-cpus).  Then run the sets with
#   sipssert -x -E opensips_image=<tag> nats event_nats cachedb_nats nats_consumer
set -e
tree=${1:?usage: build.sh <opensips-tree> [tag]}
tag=${2:-opensips-sipssert-nats:local}
here=$(cd "$(dirname "$0")" && pwd)
git -C "$tree" archive --format=tar HEAD > "$here/src.tar"
trap 'rm -f "$here/src.tar"' EXIT
if [ -n "$CPUS" ]; then
	DOCKER_BUILDKIT=0 docker build --cpuset-cpus "$CPUS" -t "$tag" "$here"
else
	docker build -t "$tag" "$here"
fi
echo "built $tag"
