for PR in $(gh pr list --repo tiborsapi/deploy_furniture_project --json number --jq '.[].number'); do
  echo "Processing PR #$PR"
  
  MODULES=$(gh pr view $PR --repo tiborsapi/deploy_furniture_project --json files --jq '.tree[] | select(.path=="backend") | .sha' )

  echo $MODULES
  
  for MODULE in $MODULES; do
    echo "Module: $MODULE"
    
    # Get latest commit for module in PR branch
    BRANCH=$(gh pr view $PR --repo tiborsapi/deploy_furniture_project --json headRefName --jq '.headRefName')
    COMMIT_SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/OWNER/REPO/commits/$BRANCH?path=modules/$MODULE | jq -r '.sha')
    
    echo "Latest commit: $COMMIT_SHA"
    
    # Find Docker image tag (from workflow runs or GHCR)
    RUN_JSON=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/OWNER/REPO/actions/runs?branch=$BRANCH&per_page=100)
    
    RUN_ID=$(echo "$RUN_JSON" | jq -r ".workflow_runs[] | select(.head_sha==\"$COMMIT_SHA\") | .id")
    
    IMAGE_TAG="$MODULE-$(echo $RUN_ID)"  # adjust if your workflow tags differently
    echo "Docker image tag: $IMAGE_TAG"
    
    # Helm deploy
    # helm upgrade myapp ./chart --set image.repository=ghcr.io/OWNER/$MODULE --set image.tag=$IMAGE_TAG
  done
done
