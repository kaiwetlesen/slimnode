#!/bin/sh

if [ -z "${1}" ] || ! [ -d "${1}" ] || [ -z "${2}" ]; then
  echo "Usage: ${0} [source modules directory] [target modules directory]"
  exit 1
fi
source_modules_dir="$1"
target_modules_dir="$2"

set -e
old_prefix="$(npm config get prefix)"
new_prefix="${HOME}/minifier"
npm config set prefix "${new_prefix}"

# Minify the packages:
npx -y minify-all-cli -s "${source_modules_dir}" -d "${target_modules_dir}"

npm config set prefix "${old_prefix}"
rm -rf "${new_prefix}"

# Strip commonly unneeded files:
find "${target_modules_dir}" -type f \( \
    -iname Makefile -or \
    -iname README -or \
    -iname README.md -or \
    -iname CHANGELOG -or \
    -iname CHANGELOG.md -or \
    -name .editorconfig -or \
    -name .gitmodules -or \
    -name .gitattributes -or \
    -name robot.html -or \
    -name .lint -or \
    -iname Gulpfile.js -or \
    -iname Gruntfile.js -or \
    -name .tern-project -or \
    -name .gitattributes -or \
    -name .editorconfig -or \
    -name .eslintrc -or \
    -name .jshintrc -or \
    -name .npmignore -or \
    -name .flowconfig -or \
    -name .documentup.json -or \
    -name .yarn-metadata.json -or \
    -name .travis.yml -or \
    -iname thumbs.db -or \
    -name .tern-port -or \
    -iname .ds_store -or \
    -iname desktop.ini -or \
    -name npm-debug.log -or \
    -name .npmrc -or \
    -iname LICENSE.txt -or \
    -iname LICENSE.md -or \
    -iname LICENSE-MIT -or \
    -iname LICENSE-MIT.txt -or \
    -iname LICENSE.BSD -or \
    -iname LICENSE-BSD -or \
    -iname LICENSE-jsbn -or \
    -iname LICENSE -or \
    -iname AUTHORS -or \
    -iname CONTRIBUTORS -or \
    -name .yarn-integrity -or \
    -name builderror.log -or \
    -name "*.md" -or \
    -name "*.sln" -or \
    -name "*.obj" -or \
    -name "*.vcxproj" -or \
    -name "*.vcxproj.filters" -or \
    \( -name '*.ts' -and \! -name '*.d.ts' \) -or \
    -name "*.jst" -or \
    -name "*.coffee" -or \
    -name "*.ps1" -or \
    -name "*.cmd" \
  \) -exec rm -rf {} \;
# Added *.cmd and *.ps1 because we don't care about Windoze thingies on Linux

# Strip commonly unneeded directories:
find "${target_modules_dir}" -type d \( \
    -name __tests__ -or \
    -name test -or \
    -name tests -or \
    -name powered-test -or \
    -name docs -or \
    -name doc -or \
    -name man -or \
    -name website -or \
    -name images -or \
    -name assets -or \
    -name example -or \
    -name examples -or \
    -name coverage -or \
    -name .nyc_output \
  \) -prune -exec rm -rf {} \;

# Replace the modules
#rm -rf "${modules_dir}"
#cp -R "${HOME}/build-${$}" "${modules_dir}"
#rm -rf "${HOME}/build-${$}"
