#!/bin/bash

set -Eeuo pipefail

mvn --batch-mode package shade:shade

# This is the Maven "target" directory
BUILD_DIR=$(mvn help:evaluate -Dexpression=project.build.directory -q -DforceStdout)

# The Maven shade plugin adds the "original-" prefix to the non-shaded JAR.
# Here we select the shaded JAR which does not have this prefix.
JAR_FILE=$(ls ${BUILD_DIR} | grep '.jar$' | grep -v '^original')
mkdir -p "${BUILD_DIR}/${DEPLOYMENT_DIR}"
cp "${BUILD_DIR}/${JAR_FILE}" "${BUILD_DIR}/${DEPLOYMENT_DIR}/${JAR_FILE}"

DEPLOYMENT_DIR_ABS="${BUILD_DIR}/${DEPLOYMENT_DIR}"
DEPLOYMENT_FILE_ABS="${DEPLOYMENT_DIR_ABS}/${JAR_FILE}"

echo "deployment-directory=${DEPLOYMENT_DIR_ABS}" >> $GITHUB_OUTPUT
echo "deployment-file=${DEPLOYMENT_FILE_ABS}" >> $GITHUB_OUTPUT
