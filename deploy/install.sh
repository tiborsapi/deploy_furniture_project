GITHUB_REPO="tiborsapi/deploy_furniture_project"
WORKDIR="/home/kisstibor/pr"
STATEFILE="$WORKDIR/deployed_commits.txt"
LOGFILE="$WORKDIR/chronejob.log"
mkdir -p "$WORKDIR"

echo "Running at $(date)" >> "$LOGFILE"

for pr in $(gh pr list --repo tiborsapi/deploy_furniture_project --json number --jq '.[].number'); do
  branch=$(gh pr view $pr --repo tiborsapi/deploy_furniture_project --json headRefName --jq '.headRefName')

  commitbe=$(gh api repos/tiborsapi/deploy_furniture_project/git/trees/$branch \
           --jq '.tree[] | select(.path=="be") | .sha')
  commitfe=$(gh api repos/tiborsapi/deploy_furniture_project/git/trees/$branch \
           --jq '.tree[] | select(.path=="fe") | .sha')


  docker manifest inspect ghcr.io/tiborsapi/diyfurniture-server:$commitbe > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Backend docker image $commitbe not found, skipping PR #pr-$pr"
    continue
  fi

  docker manifest inspect ghcr.io/tiborsapi/diyfurniture-client:$commitfe > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Frontend docker image $commitfe not found, skipping PR #pr-$pr"
    continue
  fi

  key="pr-$pr:$commitbe:$commitfe"

  # Check if this commit combo was already deployed
  if grep -q "$key" "$STATEFILE"; then
    echo "Skipping PR #$pr (already deployed with backend=$commitbe frontend=$commitfe)"
    continue
  fi

  echo "Deploying PR #pr-$pr (backend=$commitbe frontend=$commitfe)"

  # Record deployment
  echo "$key" >> "$STATEFILE"

  # Create isolated folder for PR
  PRDIR="$WORKDIR/pr-$pr"
  rm -Rf "$PRDIR"
  mkdir -p "$PRDIR"
  cd "$PRDIR"

  # Fetch PR HEAD
  git clone "https://github.com/$GITHUB_REPO.git" .
  git fetch origin pull/$pr/head:pr-$pr
  git checkout pr-$pr

  echo "Running Helm tests for PR #$PR"

  # Run your Helm commands
  kubectl delete namespace pr-$pr
  helm upgrade --install pr-$pr $PRDIR/helm/ --set frontend.tag=$commitfe --set backend.tag=$commitbe
  kubectl create secret docker-registry ghcr --docker-server=ghcr.io --docker-username=tiborsapi --docker-password="$(cat ~/.github_token)" --docker-email="kiss.tibor@ms.sapientia.ro" -n pr-$pr

  # Run helm test
  # helm test pr-$pr --namespace pr-$pr

  gh issue comment $pr --repo "$GITHUB_REPO" --body "Helm deployment ran successfully for PR #pr-$pr URL backend: https://pr-$pr.dev.sapi2025.camdvr.org:9914/api/furniture/all URL frontend: https://pr-$pr.dev.sapi2025.camdvr.org:9914/"
done
