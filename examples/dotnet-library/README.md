# .NET Library CI/CD Example

This example shows how to set up CI/CD for a .NET library project using the VolpexSystems.CICD workflows.

## Prerequisites

1. .NET 8.0+ project
2. NuGet.org API key (for publishing)
3. Repository secrets configured

## Workflow Setup

Create `.github/workflows/ci-cd.yml` in your repository:

```yaml
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
  # Validate conventional commits on PRs
  validate-commits:
    if: github.event_name == 'pull_request'
    uses: VolpexSystems/CICD/.github/workflows/conventional-commits.yml@main
    with:
      check-pr-title: true
      check-all-commits: true

  # Build and test
  build-test:
    uses: VolpexSystems/CICD/.github/workflows/dotnet-build.yml@main
    with:
      dotnet-version: '8.0.x'
      solution-path: '**/*.sln'
      configuration: 'Release'
      run-tests: true
      code-coverage: true
      sonar-enabled: true
    secrets:
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  # Security scanning
  security-scan:
    uses: VolpexSystems/CICD/.github/workflows/security-scan.yml@main
    with:
      scan-code: true
      scan-dependencies: true
      scan-secrets: true
      fail-on-severity: 'high'
    secrets:
      SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  # Semantic versioning (only on main branch)
  semantic-version:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    needs: [build-test, security-scan]
    uses: VolpexSystems/CICD/.github/workflows/semantic-version.yml@main
    with:
      release-branches: 'main'
      pre-release-branches: 'develop'
      package-manager: 'dotnet'

  # Publish packages (only on releases)
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
```

## Required Secrets

Configure these secrets in your repository settings:

- `NUGET_API_KEY`: Your NuGet.org API key
- `SONAR_TOKEN`: SonarCloud token (optional)
- `SNYK_TOKEN`: Snyk token for vulnerability scanning (optional)

## Project Configuration

### 1. Update .csproj files

Ensure your library projects have proper metadata:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <GeneratePackageOnBuild>false</GeneratePackageOnBuild>
    <IsPackable>true</IsPackable>

    <!-- Package Metadata -->
    <PackageId>VolpexSystems.YourLibrary</PackageId>
    <Title>Your Library Title</Title>
    <Description>Description of your library</Description>
    <Authors>VolpexSystems</Authors>
    <Company>VolpexSystems</Company>
    <Product>VolpexSystems Libraries</Product>
    <Copyright>Copyright © VolpexSystems 2025</Copyright>

    <!-- Repository Information -->
    <RepositoryUrl>https://github.com/VolpexSystems/YourRepository</RepositoryUrl>
    <RepositoryType>git</RepositoryType>
    <RepositoryBranch>main</RepositoryBranch>

    <!-- Package Information -->
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
    <PackageProjectUrl>https://github.com/VolpexSystems/YourRepository</PackageProjectUrl>
    <PackageReadmeFile>README.md</PackageReadmeFile>
    <PackageTags>volpexsystems;library;dotnet</PackageTags>
    <PackageReleaseNotes>See CHANGELOG.md for release notes</PackageReleaseNotes>

    <!-- Symbol Packages -->
    <IncludeSymbols>true</IncludeSymbols>
    <SymbolPackageFormat>snupkg</SymbolPackageFormat>

    <!-- Source Link -->
    <PublishRepositoryUrl>true</PublishRepositoryUrl>
    <EmbedUntrackedSources>true</EmbedUntrackedSources>
    <DebugType>embedded</DebugType>
  </PropertyGroup>

  <ItemGroup>
    <None Include="../../README.md" Pack="true" PackagePath="\" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.SourceLink.GitHub" Version="8.0.0" PrivateAssets="All" />
  </ItemGroup>
</Project>
```

### 2. Add commitlint configuration

Copy the commitlint configuration:

```bash
cp VolpexSystems.CICD/configs/commitlint.config.js .github/commitlint.config.js
```

### 3. Add dependabot configuration

Copy the dependabot configuration:

```bash
cp VolpexSystems.CICD/configs/dependabot.yml .github/dependabot.yml
```

## Workflow Behavior

### Pull Requests
- ✅ Validates conventional commit messages
- ✅ Builds and tests the solution
- ✅ Runs security scans
- ✅ Generates code coverage reports
- ✅ Performs SonarQube analysis (if configured)

### Main Branch Pushes
- ✅ All PR checks plus:
- ✅ Semantic versioning analysis
- ✅ Creates releases for breaking changes or features
- ✅ Updates CHANGELOG.md

### Releases
- ✅ Publishes packages to NuGet.org
- ✅ Publishes packages to GitHub Packages
- ✅ Includes symbol packages for debugging

## Customization

### Different .NET Versions
```yaml
build-test:
  strategy:
    matrix:
      dotnet-version: ['6.0.x', '7.0.x', '8.0.x']
  uses: VolpexSystems/CICD/.github/workflows/dotnet-build.yml@main
  with:
    dotnet-version: ${{ matrix.dotnet-version }}
```

### Multiple Solution Files
```yaml
build-test:
  uses: VolpexSystems/CICD/.github/workflows/dotnet-build.yml@main
  with:
    solution-path: 'src/VolpexSystems.MyLibrary.sln'
```

### Skip Tests for Documentation Changes
```yaml
build-test:
  if: "!contains(github.event.head_commit.message, '[skip tests]')"
```

## Troubleshooting

### Common Issues

1. **NuGet Push Fails**
   - Verify NUGET_API_KEY secret is set
   - Check package ID doesn't conflict with existing packages
   - Ensure version number is incremented

2. **SonarQube Analysis Fails**
   - Verify SONAR_TOKEN secret is set
   - Check SonarCloud project configuration
   - Ensure organization name is correct

3. **Semantic Release Fails**
   - Check commit message format
   - Verify branch configuration in semantic-release config
   - Ensure GITHUB_TOKEN has proper permissions

### Getting Help

- Check the [troubleshooting guide](../../docs/troubleshooting.md)
- Review workflow logs in the Actions tab
- Create an issue in the CICD repository
