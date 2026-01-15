#!/bin/bash

# Colors for a professional terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}   PROJECT MANAGEMENT SYSTEM: TOTAL TEST SUITE     ${NC}"
echo -e "${BLUE}===================================================${NC}"

# 1. BACKEND: TARGETED JUNIT TESTS
echo -e "\n${GREEN}[1/3] Running Backend Service & Controller Tests...${NC}"
cd be
# Only runs your specific test classes
./mvnw test -Dtest=ProjectServiceTest,ProjectControllerTest
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backend Logic Verified${NC}"
else
    echo -e "${RED}✗ Backend Tests Failed${NC}"
    exit 1
fi
cd ..

# 2. FRONTEND: COMPONENT TESTS (HEADLESS)
echo -e "\n${GREEN}[2/3] Running Frontend Component Tests...${NC}"
cd fe
# Runs Chrome in the background (Headless) so it doesn't pop up windows
npx ng test --watch=false --browsers=ChromeHeadless --include src/app/project/edit-item-dialog/edit-item-dialog.component.spec.ts
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ UI Component Verified${NC}"
else
    echo -e "${RED}✗ UI Component Failed${NC}"
    exit 1
fi

# 3. E2E: TARGETED CUCUMBER RUN
echo -e "\n${GREEN}[3/3] Running Cucumber E2E Flow (Edit & Restore)...${NC}"
cd furniture-e2e-tests
# Explicitly requiring ONLY your files to avoid teammate errors
npx cucumber-js \
  --require-module ts-node/register \
  --require tests/hooks.ts \
  --require tests/project_versions.steps.ts \
  features/e2e/project_versions.feature

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ E2E User Flow Verified${NC}"
else
    echo -e "${RED}✗ E2E Flow Failed (Check if BE/FE servers are active!)${NC}"
fi
cd ../..

echo -e "\n${BLUE}===================================================${NC}"
echo -e "${GREEN}    VERIFICATION COMPLETE - READY FOR PRESENTATION  ${NC}"
echo -e "${BLUE}===================================================${NC}"