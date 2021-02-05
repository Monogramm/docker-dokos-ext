#!/bin/bash
set -eo pipefail

declare -A compose=(
	[slim-buster]='debian'
	[alpine3.12]='alpine'
)

declare -A base=(
	[slim-buster]='debian'
	[alpine3.12]='alpine'
)

variants=(
	slim-buster
	alpine3.12
)

min_version='1.3'
dockerLatest='1.4'
dockerDefaultVariant='slim-buster'


# version_greater_or_equal A B returns whether A >= B
function version_greater_or_equal() {
	[[ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" || "$1" == "$2" ]];
}

dockerRepo="monogramm/docker-dokos-ext"
latests=(
  $( curl -fsSL 'https://gitlab.com/dokos/dokos/-/tags' | \
     grep -oE 'v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | \
     sort -urV )
  develop
)

latestsAutoinstall=( $( curl -fsSL 'https://api.github.com/repos/Monogramm/erpnext_autoinstall/tags' |tac|tac| \
	grep -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | \
	sort -urV )
	master
)

latestsRecodDevTools=( $( curl -fsSL 'https://api.github.com/repos/Monogramm/recod_frappe_devtools/tags' |tac|tac| \
	grep -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | \
	sort -urV )
	master
)

latestsOcr=( $( curl -fsSL 'https://api.github.com/repos/Monogramm/erpnext_ocr/tags' |tac|tac| \
	grep -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | \
	sort -urV )
	master
)

latestsRecodDesign=( $( curl -fsSL 'https://api.github.com/repos/Monogramm/recod_erpnext_design/tags' |tac|tac| \
	grep -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | \
	sort -urV )
	master
)

latestsFrappePwa=( $( curl -fsSL 'https://api.github.com/repos/Monogramm/frappe_pwa/tags' |tac|tac| \
	grep -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | \
	sort -urV )
	master
)

# Remove existing images
echo "reset docker images"
rm -rf ./images/
mkdir ./images/

echo "update docker images"
readmeTags=
travisEnv=
for latest in "${latests[@]}"; do
	version=$(echo "$latest" | cut -d. -f1-2)

	latestAutoinstall=${latestsAutoinstall[0]}
	latestRecodDevTools=${latestsRecodDevTools[0]}
	latestOcr=${latestsOcr[0]}
	latestRecodDesign=${latestsRecodDesign[0]}
	latestFrappePwa=${latestsFrappePwa[0]}

	# Only add versions >= "$min_version"
	if version_greater_or_equal "$version" "$min_version"; then

		for variant in "${variants[@]}"; do
			# Create the version directory with a Dockerfile.
			dir="images/$version/$variant"
			if [ -d "$dir" ]; then
				continue
			fi
			echo "Updating $latest [$version-$variant]"
			mkdir -p "$dir"

			# Copy the docker files and directories
			for name in redis_cache.conf nginx.conf mariadb.conf .env; do
				cp -a "template/$name" "$dir/"
				sed -i \
					-e 's/{{ NGINX_SERVER_NAME }}/localhost/g' \
					"$dir/$name"
			done
			for name in test hooks; do
				cp -ar "template/$name" "$dir/"
			done
			cp "template/docker-compose_mariadb.yml" "$dir/docker-compose.mariadb.yml"
			cp "template/docker-compose_postgres.yml" "$dir/docker-compose.postgres.yml"
			cp "template/docker-compose.test.yml" "$dir/docker-compose.test.yml"
			cp "template/Dockerfile.${base[$variant]}.template" "$dir/Dockerfile"
			cp "template/.dockerignore" "$dir/.dockerignore"

			# Replace the variables.
			sed -ri -e '
				s/%%VARIANT%%/'"$variant"'/g;
				s/%%VERSION%%/'"$latest"'/g;
				s/%%DODOCK_VERSION%%/'"$version"'/g;
				s/%%DOKOS_VERSION%%/'"$version"'/g;
				' "$dir/Dockerfile" \
				"$dir/test/Dockerfile" \
				"$dir/docker-compose."*.yml \
				"$dir/.env"

			sed -ri -e '
				s|DOCKER_TAG=.*|DOCKER_TAG='"$version"'|g;
				s|DOCKER_REPO=.*|DOCKER_REPO='"$dockerRepo"'|g;
				' "$dir/hooks/run"

			# Update apps default version
			sed -ri -e '
				s/ERPNEXT_AUTOINSTALL_VERSION=.*/ERPNEXT_AUTOINSTALL_VERSION='"$latestAutoinstall"'/g;
				s/RECOD_FRAPPE_DEVTOOLS=.*/RECOD_FRAPPE_DEVTOOLS='"$latestRecodDevTools"'/g;
				s/ERPNEXT_OCR_VERSION=.*/ERPNEXT_OCR_VERSION='"$latestOcr"'/g;
				s/RECOD_ERPNEXT_DESIGN=.*/RECOD_ERPNEXT_DESIGN='"$latestRecodDesign"'/g;
				s/FRAPPE_PWA=.*/FRAPPE_PWA='"$latestFrappePwa"'/g;
			' "$dir/Dockerfile"

			# Create a list of "alias" tags for DockerHub post_push
			if [ "$version" = "v$dockerLatest" ]; then
				if [ "$variant" = "$dockerDefaultVariant" ]; then
					export DOCKER_TAGS="$latest-$variant $version-$variant $variant $latest $version latest "
				else
					export DOCKER_TAGS="$latest-$variant $version-$variant $variant "
				fi
			elif [ "$version" = "$latest" ]; then
				if [ "$variant" = "$dockerDefaultVariant" ]; then
					export DOCKER_TAGS="$latest-$variant $latest "
				else
					export DOCKER_TAGS="$latest-$variant "
				fi
			else
				if [ "$variant" = "$dockerDefaultVariant" ]; then
					export DOCKER_TAGS="$latest-$variant $version-$variant $latest $version "
				else
					export DOCKER_TAGS="$latest-$variant $version-$variant "
				fi
			fi
			echo "${DOCKER_TAGS} " > "$dir/.dockertags"

			# Add README tags
			readmeTags="$readmeTags\n-   ${DOCKER_TAGS} (\`$dir/Dockerfile\`)"

			# Add Travis-CI env var
			travisEnv='\n  - VERSION='"$version"' VARIANT='"$variant"' DATABASE=mariadb'"$travisEnv"
			travisEnv='\n  - VERSION='"$version"' VARIANT='"$variant"' DATABASE=postgres'"$travisEnv"

			if [[ $1 == 'build' ]]; then
				tag="$version-$variant"
				echo "Build Dockerfile for ${tag}"
				docker build -t "${dockerRepo}:${tag}" "$dir"
			fi
		done
	fi

done

# update README.md
sed '/^<!-- >Docker Tags -->/,/^<!-- <Docker Tags -->/{/^<!-- >Docker Tags -->/!{/^<!-- <Docker Tags -->/!d}}' README.md > README.md.tmp
sed -e "s|<!-- >Docker Tags -->|<!-- >Docker Tags -->\n$readmeTags\n|g" README.md.tmp > README.md
rm README.md.tmp

# update .travis.yml
travis="$(awk -v 'RS=\n\n' '$1 == "env:" && $2 == "#" && $3 == "Environments" { $0 = "env: # Environments'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
