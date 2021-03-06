#!/bin/sh

set -e

# Extract the base64 encoded config data and write this to the KUBECONFIG
echo "$KUBE_CONFIG_DATA" | base64 --decode > /tmp/config
export KUBECONFIG=/tmp/config
kubectl config current-context

mkdir ~/.ssh
echo "$GIT_USER_SSH_KEY" | base64 --decode > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
#grep HashKnownHosts /etc/ssh/ssh_config
#cat /etc/ssh/ssh_host_*.pub
#ssh-keyscan github.com
#ssh-keyscan -H github.com
#ssh-keyscan github.com | ssh-keygen -lf -
#ssh-keyscan github.com | ssh-keygen -lf - > ~/.ssh/known_hosts
#echo "$SSH_KNOW_HOSTS" | base64 --decode > ~/.ssh/known_hosts
#ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
#grep "^github.com " ~/.ssh/known_hosts
#ssh-agent bash -c "ssh-add /tmp/key; git clone ${GIT_SSH_REPOSITRY} ./GIT_SSH_REPOSITRY";
#cat ~/.ssh/id_rsa
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
#ssh-agent bash -c "ssh-add ~/.ssh/id_rsa";
ssh-agent bash -c "ssh-add ~/.ssh/id_rsa; git clone ${GIT_SSH_REPOSITRY} ./GIT_SSH_REPOSITRY";
#grep -rn github.com /|grep rsa
#cat ~/.ssh/known_hosts
pwd
ls -la 
#git clone ${GIT_SSH_REPOSITRY} ./GIT_SSH_REPOSITRY
cd ./GIT_SSH_REPOSITRY
echo BRANCH=${GITHUB_REF##*/}
git checkout ${GITHUB_REF##*/}
pwd
ls -la 
echo YAML_FILE=${YAML_FILE}
grep -i image: ${YAML_FILE}
echo BUILD_NUMBER_PREFIX=${BUILD_NUMBER_PREFIX}
echo BUILD_NUMBER=${BUILD_NUMBER}
TAG="${BUILD_NUMBER_PREFIX}.${BUILD_NUMBER}"
echo TAG=${TAG}
DOCKER_IMAGE=$(grep image: ${YAML_FILE} | awk -F: '{printf("%s\n",$2)}' | awk '{print $1}')
DOCKER_IMAGE_SLASH=$(echo ${DOCKER_IMAGE} | sed 's#/#\\/#g')
echo DOCKER_IMAGE_SLASH=${DOCKER_IMAGE_SLASH}
sed -E "s/image: .+$/image: ${DOCKER_IMAGE_SLASH}:${TAG}/" ${YAML_FILE} > ${YAML_FILE}.tmp
mv ${YAML_FILE}.tmp ${YAML_FILE}
grep -i image: ${YAML_FILE}
cat .git/config
git config --global user.name "${GIT_USER}"
git config --global user.email "${GIT_EMAIL}"
git add -A
git diff --cached
git commit -m "Pods Sirius Settings "${TAG}
#git push
ssh-agent bash -c "ssh-add ~/.ssh/id_rsa; git push";
git log -2

