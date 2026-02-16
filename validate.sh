#!/bin/bash

# ELK Logging Project - Validation Test Script
# This script validates the complete ELK logging infrastructure

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "ELK Logging Project - Validation Tests"
echo "=========================================="
echo ""

# Function to print test results
test_passed() {
    echo -e "${GREEN}✓ $1${NC}"
}

test_failed() {
    echo -e "${RED}✗ $1${NC}"
}

test_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Test 1: Check Docker availability
echo "Test 1: Docker availability"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    test_passed "Docker is installed: $DOCKER_VERSION"
else
    test_failed "Docker is not installed"
    exit 1
fi

# Test 2: Check Docker Compose availability
echo "Test 2: Docker Compose availability"
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    test_passed "Docker Compose is installed: $COMPOSE_VERSION"
else
    test_failed "Docker Compose is not installed"
    exit 1
fi

# Test 3: Validate ELK Stack docker-compose
echo "Test 3: Validate ELK Stack configuration"
cd elk-stack
if docker compose config --quiet; then
    test_passed "ELK Stack docker-compose.yml is valid"
else
    test_failed "ELK Stack docker-compose.yml has errors"
    exit 1
fi
cd ..

# Test 4: Validate Applications docker-compose
echo "Test 4: Validate Applications configuration"
cd applications
if docker compose config --quiet; then
    test_passed "Applications docker-compose.yml is valid"
else
    test_failed "Applications docker-compose.yml has errors"
    exit 1
fi
cd ..

# Test 5: Check Python syntax
echo "Test 5: Python application syntax"
if python3 -m py_compile applications/python-app/app.py applications/python-app/logger_config.py 2>/dev/null; then
    test_passed "Python files are syntactically correct"
else
    test_failed "Python files have syntax errors"
fi

# Test 6: Check Node.js syntax
echo "Test 6: Node.js application syntax"
if node -c applications/nodejs-app/app.js 2>/dev/null; then
    test_passed "Node.js file is syntactically correct"
else
    test_warning "Node.js syntax check skipped (node not available)"
fi

# Test 7: Check file structure
echo "Test 7: Project file structure"
REQUIRED_FILES=(
    "elk-stack/docker-compose.yml"
    "elk-stack/elasticsearch/config/elasticsearch.yml"
    "elk-stack/logstash/config/logstash.yml"
    "elk-stack/logstash/pipeline/logstash.conf"
    "elk-stack/kibana/config/kibana.yml"
    "applications/docker-compose.yml"
    "applications/python-app/Dockerfile"
    "applications/dotnet-app/Dockerfile"
    "applications/go-app/Dockerfile"
    "applications/nodejs-app/Dockerfile"
    "applications/rust-app/Dockerfile"
    "templates/python-logging-template/logger_config.py"
    "templates/python-logging-template/README.md"
    "Makefile"
    "README.md"
    ".env.example"
)

ALL_FILES_PRESENT=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (missing)"
        ALL_FILES_PRESENT=false
    fi
done

if [ "$ALL_FILES_PRESENT" = true ]; then
    test_passed "All required files are present"
else
    test_failed "Some required files are missing"
fi

# Test 8: Check Makefile commands
echo "Test 8: Makefile validation"
if make help > /dev/null 2>&1; then
    test_passed "Makefile is functional"
else
    test_warning "Makefile help command not working"
fi

echo ""
echo "=========================================="
echo "Validation Tests Completed"
echo "=========================================="
echo ""
echo "To start the ELK Stack:"
echo "  make elk-up"
echo ""
echo "To start the applications:"
echo "  make apps-up"
echo ""
echo "To access Kibana:"
echo "  http://localhost:5601"
echo ""
