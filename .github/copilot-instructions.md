# GitHub Copilot Instructions

## 🎯 Overview

This document provides comprehensive guidelines for GitHub Copilot when working on the project. It covers API design, backend development, and database standards to ensure consistency and best practices across all development work.

**IMPORTANT**: This project follows Google API design principles (AIP), API-First approach, uses a custom mediator pattern, and has strict architectural standards. Follow these patterns precisely to maintain consistency and avoid introducing incorrect frameworks or patterns.

This is an notifications pipeline built with:

- .NET 8.0 with ASP.NET Core Web API
- PostgreSQL database with Dapper ORM
- Custom Mediator Pattern (NO MediatR)
- Stored Procedures for all database operations
- API-First Development following Google AIP standards
- Privacy-by-Design principles
- Angular v20 and Angular Material v20 for Front-end UI
- Flyway used for deploying database to PostgreSQL
- Auth0 for Authentication (OIDC/OAuth2)
- Cerbos for Authorization (Policy Decision Point)
- Redis for Caching and Performance
- OpenTelemetry for Observability

---

## 🧭 CODING PRINCIPLES & ENGINEERING STANDARDS

**MANDATORY**: All code suggestions and implementations MUST follow these fundamental engineering principles to ensure consistency, maintainability, and quality across the codebase.

### 🧼 Clean Code (Robert C. Martin)

- **Readability First**: Prioritize readability and expressiveness over cleverness
- **Meaningful Names**: Use intention-revealing names for variables, functions, and classes
- **Small & Focused**: Keep functions and classes small with single responsibilities
- **Eliminate Waste**: Remove dead code, redundant comments, and unnecessary complexity

### ✂️ KISS (Keep It Simple, Stupid)

- **Simplicity Over Complexity**: Avoid complexity unless absolutely necessary
- **Direct Solutions**: Prefer simple, direct solutions over clever abstractions
- **Clear Logic**: Keep logic understandable at a glance
- **Readable Code**: Code should tell a story that other developers can easily follow

### 🔁 DRY (Don't Repeat Yourself)

- **Extract Shared Logic**: Reuse code by extracting common patterns into functions or modules
- **Smart Abstraction**: Avoid boilerplate and duplication through thoughtful abstraction
- **Configuration Driven**: Use configuration and code generation for repetitive patterns
- **Template Reuse**: Create reusable templates for common architectural patterns

### 🧱 SOLID Principles (Object-Oriented Design)

- **S**ingle Responsibility: One reason to change per module/class
- **O**pen/Closed: Open to extension, closed to modification
- **L**iskov Substitution: Subtypes should work seamlessly as their base types
- **I**nterface Segregation: Prefer smaller, more specific interfaces
- **D**ependency Inversion: Depend on abstractions, not concrete implementations

### ⚠️ YAGNI (You Aren't Gonna Need It)

- **Present Focus**: Don't write code for features that might be needed later
- **Current Requirements**: Implement what's required today, not hypothetical futures
- **Iterative Development**: Build incrementally based on actual needs
- **Avoid Over-Engineering**: Don't create unnecessary abstractions or complex architectures

### ⚙️ Code Generation Guidelines

Use code generation to eliminate repetitive, schema-driven, or boilerplate-heavy tasks—**but apply it deliberately**.

#### ✅ **Appropriate Uses:**

- Generating API clients, DTOs, or serializers from OpenAPI/GraphQL specs
- Scaffolding CRUD components, infrastructure templates, or form definitions
- Automating repetitive configuration or infrastructure boilerplate
- Creating strongly-typed constants from JSON configurations (like our error system)

#### ⚠️ **Rules & Constraints:**

- Generated code MUST be readable, reviewable, and isolated from handwritten logic
- NEVER generate business-critical or complex logic
- Clearly mark and separate generated files with headers and naming conventions
- Ensure generated code follows the same quality standards as handwritten code

> **Smart generation is a productivity multiplier. Reckless generation is a maintenance hazard.**

### 🧠 Additional Engineering Heuristics

#### ✅ Command–Query Separation (CQS)

- Keep functions either *doing* (commands) or *returning* (queries)—never both
- Commands should modify state but not return data
- Queries should return data but not modify state
- This improves testability and reasoning about code behavior

#### 🧮 Functional Programming Patterns

- **Immutability**: Prefer immutable data structures where possible
- **Pure Functions**: Favor functions without side effects
- **Function Composition**: Build complex behavior through function composition
- **Declarative Style**: Focus on *what* rather than *how*

#### 🧩 Composition Over Inheritance

- Favor flexible object composition and interfaces over deep class hierarchies
- Use dependency injection for loose coupling
- Prefer aggregation and interfaces for extensibility
- Avoid tight coupling through inheritance chains

#### 🧪 Testability by Design

- Design code to be easily testable from the start
- Use dependency injection for external dependencies
- Keep business logic separate from infrastructure concerns
- Write testable code with clear inputs and outputs

#### 🤯 Principle of Least Astonishment

- Code should behave in ways that are intuitive and expected
- Follow established conventions and patterns
- Use consistent naming and structure throughout the codebase
- Minimize cognitive load for other developers

### 🎯 Application to This Project

These principles are particularly important for our notification pipeline architecture:

- **Clean Code**: Our API endpoints, domain models, and business logic must be self-documenting
- **SOLID**: Custom mediator pattern, repository patterns, and service interfaces follow these principles
- **DRY**: Error management system uses JSON configuration and code generation to eliminate duplication
- **Code Generation**: Source generators for error codes, metadata, and localization reduce boilerplate
- **Testability**: Dependency injection and clean architecture enable comprehensive unit testing
- **CQS**: Separate command handlers for mutations and query handlers for data retrieval

---

## ✅ APPROVED TECH STACK

### Core Framework

- .NET 8.0

- ASP.NET Core Web API

- Custom Mediator Pattern (IMediator)

### UI Framework

- Angular (v20+) - Microsite Architecture with Standalone Components

- Angular Material (v20+)

- AWS S3/CloudFront for static site deployment

### Authentication & Authorization

- Auth0 (v7.x+) - OIDC/OAuth2 identity provider

- Cerbos (v0.30+) - Policy Decision Point (PDP)

- Redis (v7.x+) - Caching layer for entitlements

### Data Access

- Dapper (2.1.35+)

- Npgsql (8.0.3+)

- Stored Procedures only

- Repository Pattern with BaseRepository<T>

- Flyway for deployment

### PostgreSQL Database Standards

**MANDATORY**: All database development MUST follow the comprehensive PostgreSQL patterns established in the project. See [PostgreSQL Database Guidelines](../docs/POSTGRESQL_DATABASE_GUIDELINES.md) for complete standards.

#### Schema Organization Requirements

- **Two-Schema Pattern**: `notification` (business data) and `audit` (compliance)
- **File Organization**: Each stored procedure/function in its own file
- **Naming Conventions**: snake_case throughout, descriptive business names

#### Table Design Standards

```sql
-- MANDATORY: Standard columns in all business tables
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
created_at_utc TIMESTAMP DEFAULT timezone('utc'::text, now()) NOT NULL,
updated_at_utc TIMESTAMP DEFAULT timezone('utc'::text, now()) NOT NULL,
created_by VARCHAR(100),
updated_by VARCHAR(100)

-- MANDATORY: All datetime fields MUST be UTC and use _at_utc suffix
scheduled_at_utc TIMESTAMP,
sent_at_utc TIMESTAMP,
expires_at_utc TIMESTAMP,
deleted_at_utc TIMESTAMP,

-- Use JSONB for structured data
metadata JSONB DEFAULT '{}'::jsonb,
preferences JSONB,

-- Check constraints for all business rules
CONSTRAINT chk_status CHECK (status IN ('pending', 'sent', 'failed')),
CONSTRAINT chk_priority CHECK (priority >= 1 AND priority <= 10)
```

#### Stored Procedure Standards

- **Function Naming**: Use `add_`, `set_`, `get_`, `del_` prefixes for CRUD operations
- **Parameter Naming**: Prefix all parameters with `param_` (e.g., `param_notification_id`)
- **Error Handling**: Comprehensive exception handling with business-friendly messages
- **Documentation**: All functions MUST have descriptive comments

```sql
-- ✅ CORRECT: Function naming pattern
CREATE OR REPLACE FUNCTION notification.add_notification(...)
CREATE OR REPLACE FUNCTION notification.get_notification_by_id(...)
CREATE OR REPLACE FUNCTION notification.set_notification(...)
CREATE OR REPLACE FUNCTION notification.del_notification(...)

-- ✅ CORRECT: Parameter naming
CREATE OR REPLACE FUNCTION notification.get_template_by_id(
    param_template_id UUID,
    param_version INTEGER DEFAULT NULL
)
```

#### Security and Compliance

- **Role-Based Access**: `notification_app` (runtime), `notification_reader` (reports), `notification_admin` (management)
- **Audit Logging**: All data changes logged to `audit.audit_log`
- **Privacy-by-Design**: PII fields clearly marked and handled appropriately
- **Data Retention**: Retention policies for compliance requirements

#### Performance Optimization

- **Required Indexes**: All foreign keys and query patterns properly indexed
- **JSONB Indexes**: GIN indexes for JSON query patterns
- **Partial Indexes**: Conditional indexes for filtered queries (e.g., `WHERE deleted_at IS NULL`)

#### Development Integration

- **Docker Deployment**: Automatic schema deployment via Docker initialization
- **Seed Data**: Separate development and production data scripts
- **Health Checks**: Database verification queries for monitoring
- **Migration Strategy**: Flyway-compatible structure for production deployments

**Reference**: For complete PostgreSQL guidelines, patterns, examples, and troubleshooting, see [PostgreSQL Database Guidelines](../docs/POSTGRESQL_DATABASE_GUIDELINES.md).

### Observability

- OpenTelemetry (v1.6+) - Distributed tracing and metrics

- Structured Logging with Serilog

- Correlation ID middleware for request tracking

### Testing

- xUnit framework (Backend)
- NSubstitute for mocking (Backend)
- xUnit.Assert for assertions (Backend)
- Playwright (Frontend E2E Testing) - PREFERRED for UI automation
- Jasmine + Karma (Frontend Unit Testing)
- Cypress (Frontend E2E Testing) - ALTERNATIVE to Playwright
- Custom performance testing (NO NBomber)

**Note:** Do not use FluentAssertions or any third-party assertion libraries. Use only xUnit.Assert for all backend test assertions.

### 🧪 MANDATORY UNIT TESTING REQUIREMENTS

**CRITICAL**: ALL new code MUST include comprehensive unit tests that achieve ≥95% code coverage.

#### Required Test Coverage Standards

1. **Positive Test Cases**: Test all expected successful scenarios and edge cases
2. **Negative Test Cases**: Test all error conditions, invalid inputs, and exception scenarios
3. **Boundary Conditions**: Test minimum/maximum values, empty collections, null references
4. **Code Coverage**: Minimum 95% line coverage for all new classes and methods
5. **Assertion Standards**: Use only xUnit.Assert methods (no FluentAssertions or third-party libraries)

#### Test Structure Requirements

```csharp
[Fact]
public async Task MethodName_WhenCondition_ShouldExpectedBehavior()
{
    // Arrange
    var dependency = Substitute.For<IDependency>();
    var sut = new SystemUnderTest(dependency);

    // Act
    var result = await sut.MethodAsync(validInput);

    // Assert
    Assert.True(result.IsSuccess);
    Assert.Equal(expectedValue, result.Value);
    dependency.Received(1).ExpectedCall(Arg.Any<Parameter>());
}
```

#### Test Categories Required

- **Happy Path Tests**: All successful execution paths
- **Error Handling Tests**: Exception scenarios, invalid inputs, system failures
- **Edge Case Tests**: Boundary conditions, empty/null inputs, extreme values
- **Integration Points**: Mock verification, dependency interaction validation
- **Performance Tests**: For critical paths (response times, memory usage)

#### Code Coverage Enforcement

- **Line Coverage**: ≥95% for all new classes
- **Branch Coverage**: ≥90% for all conditional logic
- **Method Coverage**: 100% for all public methods
- **Exclusions**: Only infrastructure code, DTOs, and auto-generated code may be excluded

#### Test Naming Conventions

- **Pattern**: `MethodName_WhenCondition_ShouldExpectedBehavior`
- **Examples**:
  - `CreateAsync_WhenValidCommand_ShouldReturnCloudEvent`
  - `CreateAsync_WhenBuilderNotFound_ShouldThrowInvalidOperationException`
  - `CanHandle_WhenCommandTypeIsNull_ShouldReturnFalse`

#### Mock Setup Standards

```csharp
// ✅ CORRECT: Specific mock setups with argument validation
_mockBuilder.Setup(x => x.BuildAsync(
    It.Is<SendNotificationCommand>(cmd => cmd.Type == "test.notification"),
    It.IsAny<Uri>()))
    .ReturnsAsync(expectedCloudEvent);

// ❌ INCORRECT: Overly broad mock setups
_mockBuilder.Setup(x => x.BuildAsync(It.IsAny<SendNotificationCommand>(), It.IsAny<Uri>()))
    .ReturnsAsync(expectedCloudEvent);
```

#### Test Implementation Checklist

- [ ] **Positive Cases**: All success scenarios covered
- [ ] **Negative Cases**: All error conditions tested
- [ ] **Null/Empty Inputs**: Defensive programming validated
- [ ] **Exception Handling**: All catch blocks exercised
- [ ] **Mock Verification**: All dependency interactions verified
- [ ] **Async Operations**: Proper async/await testing patterns
- [ ] **Logging Verification**: Critical log messages validated
- [ ] **Performance**: Response time assertions for critical paths

### Event Architecture

- CloudEvents (v1.0.2+) - Standardized event structure for interoperability
- AWS EventBridge - Primary event streaming platform
- Domain-specific events (UserEntitlementChanged, not generic EntityUpdated)
- Event versioning strategy for backward compatibility
- Dead letter queue patterns for failed event processing
- Selective event replay for failed event reprocessing

### GraphQL Integration

- GraphQL as supplementary query layer (not primary API)
- HotChocolate (v16+) for .NET GraphQL implementation
- REST APIs remain primary interface following Google AIP
- GraphQL used for complex data aggregation and reporting queries

### UI Design Standards

- **Microsite Architecture**: Angular 20 standalone components with focused functionality
- Create UI designs in `/docs/proposal/ui-designs/` directory
- Desktop-first approach for internal tools (not responsive mobile)
- Wireframes with Material Design component annotations
- Create HTML prototypes for the key frontend pages in `/microsite/` directory
- WCAG 2.1 AA accessibility compliance markers
- Bulk operations support (up to 10K entitlements with partial success handling)
- Real-time audit trail visualization for compliance
- Bundle size optimization (<500KB) with aggressive tree-shaking
- CDN-optimized asset management for CloudFront distribution

### Angular v20+ Development Standards

**MANDATORY**: All Angular development MUST follow these modern Angular v20+ patterns and best practices for consistency and performance optimization.

#### Core Angular Principles

- **Standalone Components**: Always use standalone components over NgModules
- **Signals-First**: Use signals for reactive state management throughout the application
- **OnPush Change Detection**: Set `changeDetection: ChangeDetectionStrategy.OnPush` in all components
- **Modern Control Flow**: Use native control flow (`@if`, `@for`, `@switch`) instead of structural directives
- **Performance Optimization**: Leverage Angular's latest performance features for optimal user experience

#### Component Architecture Standards

```typescript
// ✅ CORRECT: Modern Angular v20+ component pattern
import {
  ChangeDetectionStrategy,
  Component,
  signal,
  input,
  output,
  computed,
} from "@angular/core";

@Component({
  selector: "app-notification-card",
  templateUrl: "./notification-card.component.html",
  styleUrl: "./notification-card.component.css",
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NotificationCardComponent {
  // Use input() signal for component inputs
  readonly notification = input.required<Notification>();
  readonly isSelected = input(false);

  // Use output() function for events
  readonly notificationClick = output<string>();
  readonly selectionChange = output<boolean>();

  // Use computed() for derived state
  readonly displayStatus = computed(() => {
    const status = this.notification().status;
    return status === "sent" ? "Delivered" : status.toUpperCase();
  });

  // Use signals for local component state
  protected readonly isExpanded = signal(false);

  toggleExpanded() {
    this.isExpanded.update((expanded) => !expanded);
  }

  onNotificationClick() {
    this.notificationClick.emit(this.notification().id);
  }
}
```

#### Template Best Practices

```html
<!-- ✅ CORRECT: Modern Angular template patterns -->
<div
  class="notification-card"
  [class.expanded]="isExpanded()"
  [class.selected]="isSelected()"
>
  @if (notification(); as notif) {
  <div class="notification-header">
    <h3>{{ notif.title }}</h3>
    <span
      class="status-badge"
      [style.background-color]="getStatusColor(notif.status)"
    >
      {{ displayStatus() }}
    </span>
  </div>

  @if (isExpanded()) {
  <div class="notification-content">
    <p>{{ notif.content }}</p>

    @for (recipient of notif.recipients; track recipient.id) {
    <div class="recipient-item">
      {{ recipient.name }} - {{ recipient.email }}
    </div>
    } @if (notif.attachments.length > 0) {
    <div class="attachments">
      @for (attachment of notif.attachments; track attachment.id) {
      <a [href]="attachment.url" target="_blank"> {{ attachment.name }} </a>
      }
    </div>
    }
  </div>
  } }

  <button (click)="toggleExpanded()" [attr.aria-expanded]="isExpanded()">
    {{ isExpanded() ? 'Collapse' : 'Expand' }}
  </button>
</div>
```

#### Component Development Rules

**✅ REQUIRED Patterns:**

- Use `input()` signal instead of `@Input()` decorators
- Use `output()` function instead of `@Output()` decorators
- Use `computed()` for derived state calculations
- Set `changeDetection: ChangeDetectionStrategy.OnPush` in all components
- Keep components small and focused on single responsibility
- Use `class` bindings instead of `ngClass`
- Use `style` bindings instead of `ngStyle`
- Use native control flow (`@if`, `@for`, `@switch`) instead of structural directives

**❌ FORBIDDEN Patterns:**

- Setting `standalone: true` explicitly (Angular v20+ defaults)
- Using `@HostBinding` and `@HostListener` decorators (use `host` object instead)
- Using `ngClass` or `ngStyle` (use direct bindings)
- Using `*ngIf`, `*ngFor`, `*ngSwitch` (use modern control flow)
- Using `mutate()` on signals (use `update()` or `set()` instead)

#### State Management Patterns

```typescript
// ✅ CORRECT: Signal-based state management
export class NotificationService {
  private readonly _notifications = signal<Notification[]>([]);
  private readonly _loading = signal(false);
  private readonly _error = signal<string | null>(null);

  // Public read-only signals
  readonly notifications = this._notifications.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();

  // Computed derived state
  readonly totalNotifications = computed(() => this._notifications().length);
  readonly unreadCount = computed(
    () => this._notifications().filter((n) => !n.isRead).length
  );

  async loadNotifications() {
    this._loading.set(true);
    this._error.set(null);

    try {
      const notifications = await this.fetchNotifications();
      this._notifications.set(notifications);
    } catch (error) {
      this._error.set(error.message);
    } finally {
      this._loading.set(false);
    }
  }

  markAsRead(notificationId: string) {
    this._notifications.update((notifications) =>
      notifications.map((n) =>
        n.id === notificationId ? { ...n, isRead: true } : n
      )
    );
  }
}
```

#### Service Development Standards

```typescript
// ✅ CORRECT: Modern service pattern with inject()
import { Injectable, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";

@Injectable({
  providedIn: "root",
})
export class NotificationApiService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = "/api/v1/notifications";

  async sendNotification(
    request: SendNotificationRequest
  ): Promise<NotificationResponse> {
    return firstValueFrom(
      this.http.post<NotificationResponse>(`${this.baseUrl}`, request)
    );
  }

  async getNotificationStatus(id: string): Promise<NotificationStatus> {
    return firstValueFrom(
      this.http.get<NotificationStatus>(`${this.baseUrl}/${id}/status`)
    );
  }
}
```

#### TypeScript Best Practices

- **Strict Type Checking**: Always use strict TypeScript configuration
- **Type Inference**: Prefer type inference when types are obvious
- **Avoid `any`**: Use `unknown` instead of `any` for uncertain types
- **Interface Definitions**: Define clear interfaces for all data structures
- **Readonly Properties**: Use `readonly` for immutable properties

#### Testing Standards

```typescript
// ✅ CORRECT: Angular v20+ testing patterns
describe("NotificationCardComponent", () => {
  let component: NotificationCardComponent;
  let fixture: ComponentFixture<NotificationCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NotificationCardComponent], // Import standalone component
    }).compileComponents();

    fixture = TestBed.createComponent(NotificationCardComponent);
    component = fixture.componentInstance;
  });

  it("should toggle expanded state when button clicked", () => {
    // Test signal state changes
    expect(component.isExpanded()).toBe(false);

    component.toggleExpanded();

    expect(component.isExpanded()).toBe(true);
  });

  it("should emit notification click event", () => {
    const mockNotification = { id: "123", title: "Test" };
    spyOn(component.notificationClick, "emit");

    fixture.componentRef.setInput("notification", mockNotification);
    component.onNotificationClick();

    expect(component.notificationClick.emit).toHaveBeenCalledWith("123");
  });
});
```

#### Performance Optimization

- **Bundle Size**: Target <500KB with aggressive tree-shaking
- **Lazy Loading**: Implement lazy loading for all feature routes
- **OnPush Strategy**: Use OnPush change detection for optimal performance
- **NgOptimizedImage**: Use `NgOptimizedImage` for all static images
- **Reactive Forms**: Prefer reactive forms over template-driven forms

#### Accessibility Compliance

- **WCAG 2.1 AA**: All components must meet WCAG 2.1 AA standards
- **ARIA Attributes**: Proper ARIA labeling and descriptions
- **Keyboard Navigation**: Full keyboard accessibility support
- **Screen Reader Support**: Semantic HTML and proper roles

#### File Organization

```
src/app/
├── components/           # Reusable UI components
│   ├── notification-card/
│   │   ├── notification-card.component.ts
│   │   ├── notification-card.component.html
│   │   ├── notification-card.component.css
│   │   └── notification-card.component.spec.ts
├── services/            # Business logic services
├── models/              # TypeScript interfaces and types
├── utils/               # Utility functions
└── pages/               # Page-level components (routable)
```

### Performance & SLA Requirements

- Automated SLA reporting with service tier upgrade penalties
- Performance budgets including bundle size and memory constraints
- Circuit breaker patterns for graceful degradation

### Deployment Tools & Scripts

- Flyway for database
- Docker images for backend
- **Angular Microsite**: Static site deployment to AWS S3 with CloudFront CDN
- AWS as Cloud Provider
- **Node.js Scripts**: Cross-platform development automation
- **npm commands**: Standardized script execution (npm run start:dev)
- **bash/shell scripts**: For Linux/macOS environments
- **Docker/Podman Compose**: Container orchestration

## 🚫 FORBIDDEN FRAMEWORKS & PATTERNS

### ❌ DO NOT USE

- **Entity Framework (EF Core)** - We use Dapper + Stored Procedures
- **MediatR** - We use a custom mediator pattern (IMediator)
- **Moq** (in tests) - We use NSubstitute
- **FluentAssertions** (in tests) - We use xUnit.Assert
- **Entity-based repositories** - We use stored procedure-based repositories
- **DbContext** - We use IDbConnection with Dapper
- **LINQ to Entities** - We use Dapper with SQL
- **NBomber** - ⚠️ STRICTLY FORBIDDEN - Use custom performance testing framework
- **PowerShell scripts** - ⚠️ FORBIDDEN - Use Node.js scripts via npm commands

#### Database-Specific Forbidden Patterns

- **Entity Framework (EF Core)** - Use Dapper + PostgreSQL stored procedures only
- **LINQ to Entities** - Use stored procedures with Dapper for all data access
- **Ad-hoc SQL in code** - All SQL must be in stored procedures/functions
- **Multiple files per procedure** - Each stored procedure MUST be in its own file
- **Generic function names** - Use `add_`, `get_`, `del_` prefixes for CRUD operations
- **Sequential integer PKs** - Use UUID primary keys for all business entities
- **Unstructured JSON** - Use JSONB with proper validation and GIN indexes
- **Missing audit trails** - All data changes must be logged to `audit.audit_log`
- **Direct table access** - Applications should use stored procedures when possible

#### Angular-Specific Forbidden Patterns

- **NgModules** - Use standalone components instead
- **@Input()/@Output() decorators** - Use `input()` and `output()` functions
- **@HostBinding/@HostListener decorators** - Use `host` object in component decorator
- **ngClass/ngStyle directives** - Use direct class/style bindings
- **Structural directives** - Use modern control flow (`@if`, `@for`, `@switch`)
- **Template-driven forms** - Use reactive forms with signals
- **Constructor injection** - Use `inject()` function
- **mutate() on signals** - Use `update()` or `set()` methods
- **any type** - Use `unknown` for uncertain types

---

## 📝 MODULAR DOCUMENTATION APPROACH

### 🎯 Documentation Structure Policy

**MANDATORY**: All comprehensive documentation MUST follow a **modular approach** to avoid response length limits and improve maintainability.

#### Core Principles

1. **Main Hub Pattern**: Create a central README.md with navigation and overview
2. **Focused Modules**: Break complex topics into separate, focused files
3. **Clear Navigation**: Link between related documents with consistent structure
4. **Practical Examples**: Include working code samples in each module
5. **Cross-References**: Maintain links between related concepts

#### Required Structure for Large Documentation

```
/docs/coding guidelines & standards/{discipline}/
├── README.md                    # Main hub with navigation & quick start
├── {topic-1}.md                 # Focused topic (2-3k words max)
├── {topic-2}.md                 # Focused topic (2-3k words max)
├── {topic-3}.md                 # Focused topic (2-3k words max)
└── appendices/                  # Additional detailed examples
    ├── {detailed-examples}.md   # Complex examples and reference
    └── {troubleshooting}.md     # Common issues and solutions
```

#### Documentation Module Guidelines

- **File Size Limit**: Maximum 3,000 words per module file

- **Topic Focus**: Each file should cover ONE major concept thoroughly

- **Navigation**: Include "Next:" links at the bottom of each file

- **Code Examples**: Practical, working examples in every module

- **Cross-References**: Link to related modules and external resources

#### Example Modular Structure (Angular Documentation)

```
/docs/coding guidelines & standards/angular/
├── README.md                    # Main hub, overview, quick start
├── component-architecture.md    # Standalone components, signals, lifecycle
├── ui-privacy-patterns.md       # Data masking, consent flows, GDPR
├── testing-standards.md         # Unit, integration, E2E with Playwright
├── state-management.md          # NgRx patterns, reactive forms
├── performance-optimization.md  # Bundle optimization, lazy loading
├── accessibility-compliance.md  # WCAG 2.1 AA, screen readers
└── appendices/
    ├── complete-examples.md     # Full component implementations
    └── troubleshooting.md       # Common issues and solutions
```

#### Benefits of Modular Approach

- **Avoid Response Limits**: Keep individual responses under token limits

- **Improved Maintainability**: Easy to update specific topics

- **Better Navigation**: Developers find relevant content faster

- **Parallel Development**: Multiple team members can work on different modules

- **Focused Learning**: Concentrated content for specific learning objectives

#### Implementation Rules

1. **Always start with main hub**: Create overview and navigation first
2. **One concept per file**: Don't mix unrelated topics in a single module
3. **Consistent naming**: Use kebab-case for file names
4. **Link everything**: Maintain clear navigation between modules
5. **Update progressively**: Complete one module before starting the next

---

## 📊 TASK ESTIMATION REQUIREMENTS

### 🎯 Estimation Framework

**MANDATORY**: When any task, feature, or project work is requested, GitHub Copilot MUST provide comprehensive effort estimates using the following framework:

#### Required Estimation Components

1. **GitHub Copilot Effort Estimate**
2. **Human Developer Effort Estimate**
3. **Token Cost Analysis**
4. **Effort Breakdown by Activity**
5. **Risk Assessment & Factors**

### 📋 Estimation Template

For every task request, provide estimates in this format:

```markdown
## 📊 Task Estimation

### 🤖 GitHub Copilot Effort

- **Primary Implementation**: X hours of Copilot assistance

- **Code Generation**: Y% automation achievable

- **Documentation**: Z hours of automated generation

- **Testing**: W hours of test scaffolding/generation

### 👨‍💻 Human Developer Effort

- **Design & Architecture**: X hours of human planning

- **Code Review & Refinement**: Y hours of human oversight

- **Integration & Testing**: Z hours of human validation

- **Debugging & Troubleshooting**: W hours of human problem-solving

### 💰 Token Cost Analysis

- **Estimated Token Usage**: ~X tokens for full implementation

- **Approximate Cost**: $Y.ZZ (based on current API pricing)

- **Cost per Hour**: $A.BC average cost

### ⚖️ Effort Comparison

- **Total Copilot Hours**: X hours

- **Total Human Hours**: Y hours

- **Efficiency Ratio**: Z:1 (Copilot:Human)

- **Cost Efficiency**: $A.BC per hour vs $XX.XX developer hourly rate

### 🎯 Activity Breakdown

| Activity            | Copilot % | Human % | Total Hours |
| ------------------- | --------- | ------- | ----------- |
| Initial Setup       | 80%       | 20%     | 2 hours     |
| Core Implementation | 70%       | 30%     | 8 hours     |
| Testing             | 60%       | 40%     | 4 hours     |
| Documentation       | 90%       | 10%     | 3 hours     |
| Code Review         | 20%       | 80%     | 2 hours     |
| **TOTAL**           | **X%**    | **Y%**  | **Z hours** |

### ⚠️ Risk Factors

- **Complexity Level**: Low/Medium/High

- **Unknown Requirements**: X% of scope unclear

- **Integration Dependencies**: Y external dependencies

- **Privacy/Security Requirements**: Additional Z hours for compliance
```

### 🔍 Estimation Guidelines

#### Task Complexity Levels

**🟢 Low Complexity (1-4 hours)**

- Simple CRUD operations

- Basic UI components

- Standard documentation updates

- Routine maintenance tasks

**🟡 Medium Complexity (4-16 hours)**

- API endpoint development

- Database schema changes

- Complex UI workflows

- Integration implementations

**🔴 High Complexity (16+ hours)**

- Architecture changes

- New service implementations

- Multi-system integrations

- Major refactoring efforts

#### Copilot vs Human Effort Ratios

**Code Generation Tasks**

- Copilot: 70-80% efficiency

- Human: 20-30% oversight and refinement

**Documentation Creation**

- Copilot: 80-90% efficiency

- Human: 10-20% review and customization

**Testing Implementation**

- Copilot: 60-70% test scaffolding

- Human: 30-40% test logic and edge cases

**Architecture & Design**

- Copilot: 30-40% assistance

- Human: 60-70% strategic thinking

**Debugging & Troubleshooting**

- Copilot: 40-50% assistance

- Human: 50-60% problem-solving

#### Token Cost Considerations

**Estimated Token Rates**

- Simple responses: 500-2,000 tokens

- Medium complexity: 2,000-8,000 tokens

- Complex implementations: 8,000-32,000 tokens

- Full module creation: 16,000-64,000 tokens

**Cost Factors**

- Input token cost: ~$0.01-0.03 per 1K tokens

- Output token cost: ~$0.03-0.06 per 1K tokens

- Average blended rate: ~$0.04 per 1K tokens

### 🎯 Implementation Requirements

1. **Always Provide Estimates**: Every task request must include effort estimation
2. **Be Realistic**: Account for code review, testing, and integration time
3. **Include Unknowns**: Factor in discovery time for unclear requirements
4. **Consider Dependencies**: Account for external system dependencies
5. **Privacy Impact**: Add time for privacy compliance review when applicable

### 📈 Continuous Improvement

- Track actual vs estimated effort for calibration

- Adjust ratios based on project complexity and team experience

- Document lessons learned for future estimations

- Update cost models as API pricing changes

---

## 📋 ARCHITECTURE DECISION RECORDS (ADR)

### 🎯 ADR Requirements

**MANDATORY**: Architecture Decision Records (ADRs) MUST be generated for all major architectural decisions and design choices in the application. This ensures transparency, traceability, and knowledge preservation for the development team.

#### When to Create ADRs

ADRs are required for decisions involving:

1. **Technology Stack Changes**

   - Database technology selection
   - Framework or library additions/removals
   - Authentication/authorization mechanisms
   - Caching strategies

2. **Architectural Patterns**

   - Design pattern implementations (e.g., custom mediator)
   - Data access patterns (repository, stored procedures)
   - API design approaches (Google AIP compliance)
   - Privacy-by-design implementations

3. **Infrastructure Decisions**

   - Deployment strategies (AWS Fargate, containers)
   - Monitoring and observability tools
   - Development environment setups
   - CI/CD pipeline choices

4. **Security & Privacy**

   - Data encryption methods
   - Privacy compliance approaches (GDPR, CCPA)
   - Audit logging strategies
   - Access control mechanisms

5. **Performance & Scalability**
   - Caching layer implementations
   - Database optimization strategies
   - Load balancing approaches
   - Scaling patterns

#### ADR Structure Template

Use this template for all Architecture Decision Records:

```markdown
# ADR-XXXX: [Decision Title]

## Status

[Proposed | Accepted | Deprecated | Superseded]

## Date

[YYYY-MM-DD]

## Context

[Describe the situation requiring a decision]

## Decision

[State the architecture decision and rationale]

## Consequences

[Describe positive and negative impacts]

## Alternatives Considered

[List other options evaluated]

## Related ADRs

[Link to related decisions]

## Implementation Notes

[Technical details and considerations]

## Privacy & Security Impact

[GDPR/CCPA compliance implications]
```

#### ADR Storage and Numbering

- **Location**: Store ADRs in `/docs/adr/`

- **Naming**: Use format `ADR-NNNN-brief-title.md` (e.g., `ADR-0001-custom-mediator-pattern.md`)

- **Numbering**: Sequential numbers starting from 0001

- **Index**: Maintain `/docs/adr/README.md` with links to all ADRs

#### ADR Creation Process

1. **Identify Decision Point**: Recognize when an architectural decision is needed
2. **Create Draft ADR**: Use the template with "Proposed" status
3. **Team Review**: Share with development team for feedback
4. **Update and Accept**: Incorporate feedback and mark as "Accepted"
5. **Link to Implementation**: Reference ADR in relevant code/documentation

#### Copilot ADR Generation

When GitHub Copilot identifies an architectural decision during development:

1. **Automatically suggest** creating an ADR
2. **Generate ADR draft** using the standard template
3. **Include context** from current development work
4. **Highlight privacy/security implications**
5. **Reference related documentation** and coding guidelines

---

## 🚨 CENTRALIZED ERROR MANAGEMENT

### 🎯 Error Management Requirements

**MANDATORY**: All error handling MUST use the centralized error management system following Google AIP error standards and privacy-by-design principles.

#### Core Error Management Principles

1. **Standardized Error Codes**: Use predefined error codes from `ApplicationErrors` and `NotificationErrors`
2. **Privacy-Safe Messages**: Never expose sensitive data in error responses
3. **Structured Logging**: Include correlation IDs, severity levels, and telemetry data
4. **Retryability Guidance**: Specify whether errors are retryable and retry timing
5. **HTTP Status Mapping**: Consistent mapping of error codes to HTTP status codes

### 📋 Error System Architecture

#### Error Code Organization

```
/Notification.Application/Common/Errors/
├── ApplicationErrors.cs          # Core application error codes
├── NotificationErrors.cs         # Domain-specific notification errors
├── ErrorFactory.cs               # Factory for creating structured errors
└── NotificationErrorMetadata.cs  # Error metadata registry
```

#### Error Categories

- **System**: Infrastructure, database, external service failures
- **Validation**: Request validation, format errors, business rule violations
- **Security**: Authentication, authorization, policy violations
- **Resource**: Not found, conflicts, resource state errors
- **Business**: Domain logic violations, workflow errors
- **Privacy**: GDPR/CCPA compliance, consent, data protection
- **RateLimit**: Quota exceeded, throttling, concurrency limits

### 🔧 Implementation Guidelines

#### ✅ CORRECT Error Handling Patterns

```csharp
// Use ErrorFactory for system errors with exception details
return ErrorFactory.CreateSystemError(
    NotificationErrors.Processing.ProcessingFailed,
    ex,
    _logger,
    new { NotificationType = command.Type, RecipientCount = command.Recipients.Count });

// Use extension methods for common error scenarios
return ApplicationResultExtensions.FailValidation(
    "recipients",
    NotificationErrors.Processing.RecipientValidationFailed);

// Use predefined error codes for business logic
return ApplicationResultExtensions.FailBusiness(
    NotificationErrors.Recipient.RecipientOptedOut,
    "Recipient has opted out of this notification type");

// Privacy-compliant error handling
return ErrorFactory.CreatePrivacyError(
    NotificationErrors.Privacy.ConsentNotProvided,
    new { PolicyVersion = "v1.0" },
    _logger);
```

#### ❌ INCORRECT Error Handling Patterns

```csharp
// ❌ Don't use string literals for error codes
return ApplicationResult.Failed("SOME_ERROR", "Error message");

// ❌ Don't expose sensitive data in error messages
return ApplicationResult.Failed("ERROR", $"User {userId} email {email} failed");

// ❌ Don't use generic error messages without context
return ApplicationResult.Failed("ERROR", "Something went wrong");

// ❌ Don't ignore exception details in system errors
catch (Exception ex)
{
    return ApplicationResult.Failed("ERROR", "Failed");
}
```

### 📊 Error Code Standards

#### Naming Conventions

- **Format**: `{CATEGORY}_{SPECIFIC_ERROR}_{CONTEXT}`
- **Examples**:
  - `NOTIFICATION_PROCESSING_FAILED`
  - `VALIDATION_REQUIRED_FIELD_MISSING`
  - `SECURITY_INSUFFICIENT_PERMISSIONS`

#### Error Severity Levels

- **Critical**: System-threatening, requires immediate attention
- **High**: Service degradation, user-impacting errors
- **Medium**: Recoverable errors, retry recommended
- **Low**: Expected errors, informational

#### HTTP Status Code Mapping

| Error Category | Default HTTP Status            | Examples                             |
| -------------- | ------------------------------ | ------------------------------------ |
| **Validation** | 400 Bad Request                | Missing fields, invalid format       |
| **Security**   | 401/403 Unauthorized/Forbidden | Authentication, authorization        |
| **Resource**   | 404/409 Not Found/Conflict     | Missing resources, state conflicts   |
| **RateLimit**  | 429 Too Many Requests          | Quota exceeded, throttling           |
| **System**     | 500 Internal Server Error      | Database failures, external services |
| **Privacy**    | 403 Forbidden                  | Consent required, data protection    |

### 🔒 Privacy-Compliant Error Handling

#### Required Privacy Protections

1. **No PII in Error Messages**: Never include personal data in error responses
2. **Sanitized Logging**: Remove sensitive data before logging
3. **Compliance Audit Trail**: Log privacy errors for compliance reporting
4. **User-Friendly Messages**: Provide helpful but safe error messages

#### Privacy Error Examples

```csharp
// ✅ CORRECT: Privacy-safe error handling
return ErrorFactory.CreatePrivacyError(
    NotificationErrors.Privacy.ConsentNotProvided,
    new {
        ConsentType = "marketing",
        PolicyReference = "PRIVACY_POLICY_v1.0",
        // No user identifiers or personal data
    },
    _logger);

// ❌ INCORRECT: Exposes personal data
return ApplicationResult.Failed("CONSENT_ERROR",
    $"User {email} has not provided consent for {personalizedContent}");
```

### 📈 Error Monitoring and Telemetry

#### Required Telemetry Tags

- `error.code`: Standardized error code
- `error.category`: Error category classification
- `error.severity`: Error severity level
- `error.retryable`: Whether the error is retryable
- `error.http_status`: HTTP status code

#### Structured Logging Format

```csharp
_logger.LogError(ex,
    "Error occurred: {ErrorCode} - {Message}. Category: {Category}, Severity: {Severity}, Details: {@Details}",
    errorCode, message, category, severity, contextDetails);
```

### 🔄 Retry Logic Guidelines

#### Retryable Error Identification

- **System Errors**: Database connection failures, external service timeouts
- **Rate Limit Errors**: Quota exceeded, temporary throttling
- **Transient Failures**: Network issues, temporary service unavailability

#### Retry Configuration

```csharp
// Configure retry delays in error metadata
RetryAfter = TimeSpan.FromSeconds(30),  // Short delays for system errors
RetryAfter = TimeSpan.FromMinutes(15),  // Longer delays for service unavailability
RetryAfter = TimeSpan.FromHours(1),     // Rate limit resets
```

### 🧪 Testing Error Handling

#### Required Test Categories

1. **Error Code Coverage**: Test all defined error codes are reachable
2. **Privacy Compliance**: Verify no PII in error responses
3. **HTTP Status Mapping**: Validate correct status codes returned
4. **Retry Logic**: Test retryable vs non-retryable errors
5. **Telemetry Integration**: Verify structured logging and metrics

#### Test Example Pattern

```csharp
[Fact]
public async Task HandleAsync_WhenProcessingFails_ReturnsCorrectErrorCode()
{
    // Arrange
    var command = new SendNotificationCommand { /* test data */ };
    _mockEventRouter.Setup(x => x.RouteAsync(It.IsAny<CloudEvent>(), It.IsAny<CancellationToken>()))
               .ThrowsAsync(new InvalidOperationException("Test exception"));

    // Act
    var result = await _handler.HandleAsync(command);

    // Assert
    Assert.False(result.IsSuccess);
    Assert.Equal(NotificationErrors.Processing.ProcessingFailed, result.Error);

    // Verify telemetry and logging
    _mockLogger.Verify(x => x.Log(
        LogLevel.Error,
        It.IsAny<EventId>(),
        It.Is<It.IsAnyType>((v, t) => v.ToString().Contains(NotificationErrors.Processing.ProcessingFailed)),
        It.IsAny<Exception>(),
        It.IsAny<Func<It.IsAnyType, Exception, string>>()), Times.Once);
}
```

### 📚 Error Management Documentation

#### Required Documentation

1. **Error Code Registry**: Maintain up-to-date list of all error codes
2. **Troubleshooting Guide**: Common errors and resolution steps
3. **API Documentation**: Error responses in OpenAPI specifications
4. **Monitoring Playbooks**: Alert thresholds and response procedures

#### Error Code Registry Format

```markdown
## Error Code: NOTIFICATION_PROCESSING_FAILED

- **Category**: System
- **HTTP Status**: 500 Internal Server Error
- **Severity**: High
- **Retryable**: Yes (after 1 minute)
- **Description**: General notification processing failure
- **Common Causes**: Database connection issues, external service failures
- **Resolution**: Check system health, retry after delay
- **Related Metrics**: `notification_processing_errors_total`
```

### 🎯 Implementation Checklist

#### Error System Compliance

- [ ] **Error Codes**: Use predefined constants from error registries
- [ ] **Error Factory**: Use `ErrorFactory` or extension methods for error creation
- [ ] **Privacy Safe**: No PII in error messages or logs
- [ ] **Structured Logging**: Include correlation IDs and structured data
- [ ] **HTTP Status**: Correct status code mapping implemented
- [ ] **Retry Logic**: Retryable errors identified and configured
- [ ] **Telemetry**: Error metrics and tracing integrated
- [ ] **Testing**: Error scenarios covered in unit and integration tests

#### Error Response Validation

- [ ] **Consistent Format**: All error responses follow same structure
- [ ] **User-Friendly**: Error messages are helpful but safe
- [ ] **Actionable**: Users understand how to resolve the error
- [ ] **Localized**: Error messages support multiple languages
- [ ] **Compliant**: Privacy regulations (GDPR/CCPA) adhered to

### 🚀 Advanced Error Handling

#### Circuit Breaker Integration

```csharp
// Use error codes to trigger circuit breaker logic
if (result.GetErrorCategory() == ErrorCategory.External &&
    result.GetErrorSeverity() >= ErrorSeverity.High)
{
    _circuitBreaker.RecordFailure(result.Error);
}
```

#### Error Aggregation

```csharp
// Aggregate multiple validation errors
var errors = new List<string>();
if (invalidRecipients.Any())
    errors.Add(NotificationErrors.Processing.RecipientValidationFailed);
if (invalidTemplate)
    errors.Add(NotificationErrors.Processing.TemplateNotFound);

return errors.Any()
    ? ApplicationResultExtensions.FailValidation("request", string.Join(",", errors))
    : ApplicationResult.Success;
```

This centralized error management system ensures consistent, privacy-compliant, and observable error handling across the entire notification pipeline while following Google AIP standards and architectural best practices.

---

## 📋 THIRD-PARTY NOTICES REQUIREMENTS

### 🎯 Third-Party Notices Overview

**MANDATORY**: All projects MUST include a comprehensive `THIRD-PARTY-NOTICES.md` file that documents licenses and notices for all third-party dependencies. This ensures legal compliance, transparency, and proper attribution for all external libraries and components used in the project.

#### When to Create/Update Third-Party Notices

Third-party notices are required for:

1. **NuGet Package Dependencies**
   - All direct and transitive NuGet package dependencies
   - Package license information and attribution
   - Version-specific license requirements

2. **Open Source Components**
   - External libraries and frameworks
   - Code snippets and utilities from open source projects
   - Modified or derived open source code

3. **Commercial Dependencies**
   - Licensed commercial libraries
   - Third-party services with license requirements
   - Proprietary components with attribution requirements

4. **JavaScript/NPM Dependencies** (if applicable)
   - Frontend package dependencies
   - Development tool dependencies
   - Build system components

#### Third-Party Notices Structure Template

Based on the Metalama format, use this structure for `THIRD-PARTY-NOTICES.md`:

```markdown
# Third-Party Notices

This file lists and documents the licenses and notices for third-party dependencies of the [Project Name] repository.

> **Warning**  
> This file pertains to the whole [Project Name] repository. If you find this file in a NuGet package, it does not mean that this package has all the dependencies listed here. The relevance of the dependency for any package or tool is mentioned in the table below.

> **Warning**  
> In the event that we accidentally failed to list a required notice, please bring it to our attention. Post an issue or email us at [contact@volpexsystems.com](mailto:contact@volpexsystems.com).

This file is semi-automatically generated by the build process.

## List of NuGet Dependencies

This product has dependencies that are categorized according to their typical use case:

• **Default**: These dependencies typically ship and execute with the end-user product.
• **Development**: These dependencies are typically used during development only.

> **Note**  
> Some dependencies have been intentionally excluded from this list. See the list of exclusions below.

## List of Dependencies

| Package Name | Version | License | Authors | URL | Category | Used By |
|--------------|---------|---------|---------|-----|----------|---------|
| Serilog | 4.3.0 | Apache-2.0 | Nicholas Blumhardt | https://serilog.net/ | Default | VolpexSystems.Logging.Serilog |
| Example.Package | 1.0.0 | MIT | Example Author | https://example.com | Development | Test.Project |

## Exclusions

The dependencies from the following namespaces were excluded from this declaration of dependencies:

| Namespace/Package Prefix | Reason |
|--------------------------|--------|
| Microsoft | System/Platform dependency |
| System | System/Platform dependency |
| NETStandard | System/Platform dependency |
| Runtime | System/Platform dependency |
| VolpexSystems | Current repository |

## License Notices for [Package Name]

The following packages are consumed from this project: `PackageName`.

This project is used by the following of our packages: `VolpexSystems.ProjectName`.

> [Full license text content here]
```

#### Exclusion Policy for Microsoft Dependencies

**MANDATORY**: Microsoft dependencies MUST be excluded from third-party notices and listed in the exclusions section. This includes:

##### Microsoft Exclusions

| Namespace/Package Prefix | Reason | Examples |
|--------------------------|--------|----------|
| **Microsoft*** | System/Platform dependency | Microsoft.AspNetCore.*, Microsoft.Extensions.*, Microsoft.EntityFrameworkCore.* |
| **System*** | System/Platform dependency | System.Text.Json, System.Collections.Concurrent |
| **NETStandard** | System/Platform dependency | NETStandard.Library |
| **Runtime** | System/Platform dependency | Microsoft.NETCore.App |

##### Microsoft Packages to Exclude

```markdown
## Exclusions

The dependencies from the following namespaces were excluded from this declaration of dependencies:

| Namespace/Package Prefix | Reason |
|--------------------------|--------|
| Microsoft | System/Platform dependency - Core .NET platform components |
| System | System/Platform dependency - Base Class Library components |
| NETStandard | System/Platform dependency - .NET Standard Library |
| Runtime | System/Platform dependency - .NET Runtime components |
| [YourCompany] | Current repository - Internal packages |
```

#### Automated Third-Party Notice Generation

**RECOMMENDED**: Implement automated generation of third-party notices as part of the build process:

##### Build Integration

```xml
<!-- Add to project file for automated license detection -->
<PackageReference Include="Microsoft.SourceLink.GitHub" Version="8.0.0" PrivateAssets="All"/>
<PackageReference Include="DotNetLicenses" Version="1.0.0" PrivateAssets="All">
  <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
</PackageReference>
```

##### PowerShell Script Example

```powershell
# Generate-ThirdPartyNotices.ps1
param(
    [string]$ProjectPath = ".",
    [string]$OutputPath = "THIRD-PARTY-NOTICES.md"
)

# Scan for NuGet packages and licenses
$packages = dotnet list package --include-transitive --format json | ConvertFrom-Json

# Filter out Microsoft packages
$filteredPackages = $packages.projects.frameworks.topLevelPackages | 
    Where-Object { -not $_.id.StartsWith("Microsoft.") -and 
                   -not $_.id.StartsWith("System.") -and
                   -not $_.id.StartsWith("NETStandard.") }

# Generate third-party notices file
# Implementation details...
```

#### Manual Package License Verification

For packages not automatically detected, manually verify licenses:

1. **Check Package Source**: Verify license information on NuGet.org
2. **Review License Files**: Check for LICENSE, NOTICE, or COPYING files
3. **Consult Project Repository**: Review source repository for license details
4. **Document Uncertainty**: Flag packages with unclear licensing

#### License Categories and Requirements

##### Common License Types

| License Type | Attribution Required | Source Code Disclosure | Commercial Use |
|-------------|---------------------|----------------------|----------------|
| **MIT** | Yes | No | Allowed |
| **Apache 2.0** | Yes | No | Allowed |
| **BSD** | Yes | No | Allowed |
| **GPL 2.0/3.0** | Yes | Yes | Restricted |
| **LGPL** | Yes | Conditional | Conditional |
| **Proprietary** | Varies | No | License-dependent |

##### Attribution Requirements

For packages requiring attribution:

```markdown
## License notices for [PackageName]

The following packages are consumed from this project: `PackageName`.

This project is used by the following of our packages: `Your.Package.Name`.

> [Complete license text as provided by the package]
```

#### Third-Party Notice Maintenance

##### Regular Updates

1. **Build Integration**: Update notices automatically during build process
2. **Dependency Changes**: Update when adding/removing/updating packages
3. **License Changes**: Monitor for license changes in existing dependencies
4. **Quarterly Reviews**: Conduct regular compliance reviews

##### Validation Checklist

- [ ] **All Dependencies Listed**: Every third-party package is documented
- [ ] **Microsoft Exclusions**: System dependencies properly excluded
- [ ] **License Text Complete**: Full license text included for attribution
- [ ] **Version Accuracy**: Package versions match actual usage
- [ ] **Attribution Complete**: Author and URL information included
- [ ] **Category Classification**: Default vs Development properly categorized
- [ ] **Contact Information**: Valid contact for license inquiries

#### Compliance Verification

##### Legal Review Process

1. **Initial Review**: Legal team reviews third-party notices for new projects
2. **Change Review**: Legal approval for new dependencies with restrictive licenses
3. **Audit Trail**: Maintain documentation of license compliance decisions
4. **Risk Assessment**: Evaluate license compatibility with project goals

##### Documentation Requirements

```markdown
## Compliance Documentation

### License Compatibility Matrix
- **MIT/Apache/BSD**: Compatible with commercial and open source projects
- **GPL**: Requires source code disclosure - avoid for proprietary projects
- **LGPL**: Dynamic linking allowed - static linking requires disclosure
- **Proprietary**: Review individual license terms

### Approval Process
1. Technical team identifies new dependency requirement
2. Legal team reviews license compatibility
3. Architecture team approves dependency inclusion
4. Third-party notices updated automatically
```

#### Template Files

##### Complete THIRD-PARTY-NOTICES.md Template

```markdown
# Third-Party Notices

This file lists and documents the licenses and notices for third-party dependencies of the VolpexSystems.[ProjectName] repository.

> **Warning**  
> This file pertains to the whole VolpexSystems.[ProjectName] repository. If you find this file in a NuGet package, it does not mean that this package has all the dependencies listed here.

> **Warning**  
> In the event that we accidentally failed to list a required notice, please bring it to our attention. Post an issue or contact us at [legal@volpexsystems.com](mailto:legal@volpexsystems.com).

This file is automatically generated by the build process.

## List of NuGet Dependencies

This product has dependencies that are categorized according to their typical use case:

• **Default**: These dependencies typically ship and execute with the end-user product.
• **Development**: These dependencies are typically used during development only.

> **Note**  
> Some dependencies have been intentionally excluded from this list. See the list of exclusions below.

## List of Dependencies

| Package Name | Version | License | Authors | URL | Category | Used By |
|--------------|---------|---------|---------|-----|----------|---------|
| Serilog | 4.3.0 | Apache-2.0 | Nicholas Blumhardt | https://serilog.net/ | Default | VolpexSystems.Logging.Serilog |

## Exclusions

The dependencies from the following namespaces were excluded from this declaration of dependencies:

| Namespace/Package Prefix | Reason |
|--------------------------|--------|
| Microsoft | System/Platform dependency |
| System | System/Platform dependency |
| NETStandard | System/Platform dependency |
| Runtime | System/Platform dependency |
| VolpexSystems | Current repository |

## License notices for Serilog

The following packages are consumed from this project: `Serilog`.

This project is used by the following of our packages: `VolpexSystems.Logging.Serilog`.

> Apache License
> Version 2.0, January 2004
> http://www.apache.org/licenses/
> 
> [Full Apache 2.0 license text...]
```

### 🎯 Implementation Requirements

1. **Always Include**: Every project must have a THIRD-PARTY-NOTICES.md file
2. **Automate When Possible**: Integrate license detection into build process
3. **Exclude Microsoft**: All Microsoft/System dependencies go in exclusions
4. **Complete Attribution**: Include full license text for packages requiring it
5. **Regular Updates**: Keep notices current with dependency changes

### 📈 Continuous Compliance

- **Build Validation**: Verify third-party notices are current during builds
- **Dependency Monitoring**: Track license changes in existing dependencies
- **Legal Integration**: Maintain communication with legal team for compliance
- **Documentation**: Keep compliance procedures well-documented and accessible

This third-party notices system ensures legal compliance, proper attribution, and transparency for all external dependencies while maintaining clear separation between system dependencies and third-party libraries requiring attribution.
