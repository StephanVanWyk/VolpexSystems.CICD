#!/bin/bash

# VolpexSystems.CICD Repository Setup Script
# This script helps set up a new repository with standard CI/CD workflows

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CICD_REPO="VolpexSystems/CICD"
CICD_VERSION="main"

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo
    echo "🚀 VolpexSystems.CICD Repository Setup"
    echo "======================================"
    echo
}

print_usage() {
    echo "Usage: $0 [PROJECT_TYPE] [OPTIONS]"
    echo
    echo "Project Types:"
    echo "  dotnet-library    - .NET library with NuGet publishing"
    echo "  dotnet-api        - ASP.NET Core API with deployment"
    echo "  angular-app       - Angular application with CDN deployment"
    echo "  microservices     - Multi-service repository with orchestration"
    echo
    echo "Options:"
    echo "  --repo-name       - Repository name (default: current directory)"
    echo "  --branch          - Default branch name (default: main)"
    echo "  --sonar           - Enable SonarQube integration"
    echo "  --snyk            - Enable Snyk security scanning"
    echo "  --dry-run         - Show what would be done without making changes"
    echo "  --help            - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 dotnet-library --repo-name MyLibrary --sonar"
    echo "  $0 dotnet-api --branch main --snyk"
    echo "  $0 angular-app --dry-run"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository. Please run 'git init' first."
        exit 1
    fi

    # Check if GitHub CLI is available
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI not found. Some features may not work."
    fi

    # Check if we have a remote origin
    if ! git remote get-url origin &> /dev/null; then
        log_warning "No remote origin set. You may need to configure it manually."
    fi

    log_success "Prerequisites check completed"
}

create_github_directories() {
    log_info "Creating .github directory structure..."

    mkdir -p .github/workflows
    mkdir -p .github/ISSUE_TEMPLATE

    log_success "Directory structure created"
}

setup_dotnet_library() {
    log_info "Setting up .NET library CI/CD..."

    # Create main CI/CD workflow
    cat > .github/workflows/ci-cd.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [published]

permissions:
  contents: read
  security-events: write
  packages: write

jobs:
  validate-commits:
    if: github.event_name == 'pull_request'
    uses: VolpexSystems/CICD/.github/workflows/conventional-commits.yml@main
    with:
      check-pr-title: true
      check-all-commits: true

  build-test:
    uses: VolpexSystems/CICD/.github/workflows/dotnet-build.yml@main
    with:
      dotnet-version: '8.0.x'
      solution-path: '**/*.sln'
      configuration: 'Release'
      run-tests: true
      code-coverage: true
      sonar-enabled: ${{ vars.ENABLE_SONAR == 'true' }}
    secrets:
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  security-scan:
    uses: VolpexSystems/CICD/.github/workflows/security-scan.yml@main
    with:
      scan-code: true
      scan-dependencies: true
      scan-secrets: true
      fail-on-severity: 'high'
    secrets:
      SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  semantic-version:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    needs: [build-test, security-scan]
    uses: VolpexSystems/CICD/.github/workflows/semantic-version.yml@main
    with:
      release-branches: 'main'
      pre-release-branches: 'develop'
      package-manager: 'dotnet'

  publish-packages:
    if: github.event_name == 'release'
    needs: [build-test, security-scan]
    uses: VolpexSystems/CICD/.github/workflows/nuget-publish.yml@main
    with:
      package-path: 'src/**/*.csproj'
      include-symbols: true
      github-packages: true
    secrets:
      NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF

    log_success ".NET library CI/CD workflow created"
}

setup_configuration_files() {
    log_info "Setting up configuration files..."

    # Copy commitlint configuration
    if [[ -f "configs/commitlint.config.js" ]]; then
        cp configs/commitlint.config.js .github/commitlint.config.js
    else
        # Create default configuration
        cat > .github/commitlint.config.js << 'EOF'
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'test', 'chore', 'perf', 'build', 'ci', 'revert'
    ]],
    'scope-enum': [2, 'always', [
      'api', 'ui', 'core', 'auth', 'db', 'config',
      'deps', 'ci', 'docs', 'test', 'security'
    ]],
    'subject-case': [2, 'always', 'lower-case'],
    'header-max-length': [2, 'always', 100]
  }
};
EOF
    fi

    # Copy dependabot configuration
    if [[ -f "configs/dependabot.yml" ]]; then
        cp configs/dependabot.yml .github/dependabot.yml
    else
        # Create default configuration
        cat > .github/dependabot.yml << 'EOF'
version: 2
updates:
  - package-ecosystem: "nuget"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "nuget"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    labels:
      - "dependencies"
      - "github-actions"
EOF
    fi

    log_success "Configuration files created"
}

create_readme_template() {
    if [[ ! -f "README.md" ]]; then
        log_info "Creating README.md template..."

        cat > README.md << EOF
# ${REPO_NAME}

Description of your project.

## 🚀 Features

- Feature 1
- Feature 2
- Feature 3

## 📦 Installation

\`\`\`bash
dotnet add package ${REPO_NAME}
\`\`\`

## 🛠️ Usage

\`\`\`csharp
// Usage examples
\`\`\`

## 🏗️ Development

### Prerequisites

- .NET 8.0+
- Your favorite IDE

### Building

\`\`\`bash
dotnet build
\`\`\`

### Testing

\`\`\`bash
dotnet test
\`\`\`

## 📝 Contributing

1. Fork the repository
2. Create your feature branch (\`git checkout -b feat/amazing-feature\`)
3. Commit your changes (\`git commit -m 'feat: add amazing feature'\`)
4. Push to the branch (\`git push origin feat/amazing-feature\`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- VolpexSystems team
- Contributors and community
EOF

        log_success "README.md template created"
    else
        log_info "README.md already exists, skipping"
    fi
}

print_setup_summary() {
    echo
    log_success "🎉 Repository setup completed!"
    echo
    echo "Next steps:"
    echo "1. Configure repository secrets:"
    echo "   - NUGET_API_KEY (for package publishing)"
    echo "   - SONAR_TOKEN (if using SonarQube)"
    echo "   - SNYK_TOKEN (if using Snyk)"
    echo
    echo "2. Set repository variables (optional):"
    echo "   - ENABLE_SONAR=true (to enable SonarQube)"
    echo
    echo "3. Review and customize the generated workflows"
    echo "4. Commit and push your changes"
    echo
    echo "For more information, see:"
    echo "- https://github.com/${CICD_REPO}/blob/main/docs/README.md"
    echo "- https://github.com/${CICD_REPO}/tree/main/examples"
}

# Main script logic
main() {
    print_header

    # Parse command line arguments
    PROJECT_TYPE=""
    REPO_NAME=$(basename "$(pwd)")
    BRANCH_NAME="main"
    ENABLE_SONAR=false
    ENABLE_SNYK=false
    DRY_RUN=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            dotnet-library|dotnet-api|angular-app|microservices)
                PROJECT_TYPE="$1"
                shift
                ;;
            --repo-name)
                REPO_NAME="$2"
                shift 2
                ;;
            --branch)
                BRANCH_NAME="$2"
                shift 2
                ;;
            --sonar)
                ENABLE_SONAR=true
                shift
                ;;
            --snyk)
                ENABLE_SNYK=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    # Validate project type
    if [[ -z "$PROJECT_TYPE" ]]; then
        log_error "Project type is required"
        print_usage
        exit 1
    fi

    # Check prerequisites
    check_prerequisites

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: The following actions would be performed:"
        echo "- Create .github directory structure"
        echo "- Set up $PROJECT_TYPE CI/CD workflow"
        echo "- Create configuration files"
        echo "- Create README.md template (if not exists)"
        exit 0
    fi

    # Execute setup
    create_github_directories

    case $PROJECT_TYPE in
        dotnet-library)
            setup_dotnet_library
            ;;
        *)
            log_error "Project type '$PROJECT_TYPE' not yet implemented"
            exit 1
            ;;
    esac

    setup_configuration_files
    create_readme_template
    print_setup_summary
}

# Run main function
main "$@"
