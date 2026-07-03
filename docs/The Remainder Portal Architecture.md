# **High-Fidelity System Architecture and Product Specification for The Remainder Portal**

## **Module 1: Product Requirement Document (PRD)**

### **Visual Language and Motion Design System**

The visual design system of The Remainder Portal represents an artistic departure from typical mobile interfaces, replacing dark, high-contrast cyberpunk grids with a "Light Ethereal Elegant Fantasy" aesthetic tailored for a modern aristocratic narrative setting. The primary interface is constructed around a palette of glowing alabaster, frosted glassmorphic layers, luminous warm-gold highlights, and subtle, iridescent gradient paths.  
This delicate aesthetic is implemented natively in Flutter using hardware-accelerated rendering primitives through the Impeller engine. Frosted glass surfaces are rendered using a combination of BackdropFilter and ClipRRect to limit repaint boundaries and maintain consistent performance. The Gaussian blur coefficients must be tuned within strict performance parameters to prevent rendering bottlenecks:  
\\sigma\_x, \\sigma\_y \\in \[6.0, 12.0\]  
Exceeding these values causes rendering slowdowns on lower-end mobile devices. Glass containers are styled with low-opacity, light-tinted fills (5\\% to 8\\% opacity) over backgrounds featuring vibrant radial gradients to produce a frosted, luminous effect. In light mode, the default opacity of the container fill is adjusted to 0.50–0.65 to prevent the frosted surface from appearing dull or gray.  
To highlight interactive elements without adding visual noise, layouts use sub-pixel borders (1.0\\text{ dp} thickness) styled with thin white or warm-gold gradients. Subtle iridescent accents are generated using custom fragment shaders compiled directly via Flutter's FragmentProgram API, running on the device GPU to keep the main thread free.  
Animations in the portal use custom spring-based physics to create an elegant, magical feel. Interface interactions use an underdamped spring-mass-damper system to provide natural, tactile feedback. The physical behavior of interactive panels is governed by the following equations:  
\\frac{d^2x}{dt^2} \+ 2\\zeta\\omega\_n\\frac{dx}{dt} \+ \\omega\_n^2x \= 0 \\zeta \= \\frac{c}{2\\sqrt{km}} \\approx 0.85  
These equations define the relationship between the damping ratio (\\zeta), damping coefficient (c), spring stiffness (k), and mass (m). Keeping the damping ratio slightly below 1.0 produces a responsive rebound effect, giving gestures on mobile devices a fluid, elastic feel.

### **User Personas and Workflows**

To support a private roleplay community of 15+ active members, the portal segmentally partitions access privileges and interface capabilities across two core user personas.

| Persona Profile | Access Level | Primary Behavioral Workflows | Native Tool Requirements |
| :---- | :---- | :---- | :---- |
| **The Player** (Active Community Member) | Low-Privilege, Read-Only / Self-Write (Character Profile) | Browses chronicles, searches the community roster, submits character updates, reads system-generated world summaries. | Ethereal UI, fluid swipe gestures, persistent local search cache, storybook-style timeline. |
| **The Administrator** (Lore Architect & Adjudicator) | High-Privilege, Read-Write Administrative | Evaluates applicant answer sheets, reviews AI-driven grading diagnostics, verifies faceclaims, triggers weekly summary cycles. | High-density tables, multi-tiered AI scoring panels, database transactional writing, state broadcast. |

### **User Stories**

To translate these workflows into structured development targets, user actions are defined as functional requirements in the table below.

| User Role | Narrative Goal / Action | Technical Acceptance Criteria |
| :---- | :---- | :---- |
| **Player** | As a player, I want to search and filter the character database seamlessly so that I can quickly verify active faceclaims and character houses. | The application uses local client-side caching to return filtered search results in less than 100\\text{ ms}. |
| **Player** | As a player, I want to access weekly chronicle summaries so that I can keep up with the narrative without reading through long chat history files. | Summaries are parsed from a RAG pipeline and rendered in a storybook interface with deep-linked citations. |
| **Admin** | As an admin, I want to review automated grading recommendations for applications so that I can quickly assess lore compliance and tone consistency. | Shows automated, side-by-side diagnostic scores from DeepSeek-V4-Pro and Groq-hosted Llama models. |
| **Admin** | As an admin, I want to approve or decline applicant submissions directly from my mobile device so that database logs update automatically. | Actions execute atomic, signed transactions to the backend, sending real-time update notifications to active users. |

### **Functional Specifications**

#### **Mobile-First Adaptive Layout Engine**

The application employs an adaptive layout engine that dynamically restructures tables and data cards based on viewport boundaries. Mobile viewports (W \< 600\\text{ dp}) collapse complex multi-column grids into swipeable, self-contained glassmorphic cards. Each card displays high-priority metadata (such as character name, faceclaim status, and faction affiliation) and nests secondary details within expandable modal bottom sheets. Desktop and web viewports (W \\ge 1024\\text{ dp}) expand these cards into high-density tables that support nested detail views and side-by-side comparison panels.

#### **Automated Admittance Pipeline**

Administrators have access to a dedicated onboarding workspace to review and manage applicant answer sheets. When a new application is submitted, the system triggers parallel evaluation pipelines. DeepSeek-V4-Pro parses the text to evaluate compliance with established lore, checking for historical or structural contradictions in the character’s background. Simultaneously, a Groq-hosted Llama instance performs high-speed text analysis to verify formatting rules, flag missing details, and evaluate tone alignment.  
The evaluation dashboard displays these findings as color-coded warning indicators and analytical breakdown summaries. Faceclaim availability is cross-referenced automatically against active database records, flagging conflicts before an administrator issues an approval. Approving or declining an application triggers atomic database transactions that update the community roster and broadcast real-time state changes to active users.

#### **Public Community Roster**

The public roster displays active community members using a staggered, infinite-scroll grid of floating glassmorphic cards. Each card displays a high-resolution portrait, active attributes, and status indicators. Selecting a card opens an expanded profile view with a transition animation that preserves visual context.  
The roster includes sorting and filtering controls, allowing users to browse characters by house, lineage, or faceclaim origin. Search inputs use client-side debounce mechanisms (150\\text{ ms} window) and query a local database cache, ensuring search results update smoothly without lag.

#### **Chronicles and World State**

The narrative timeline is presented as an interactive, digital storybook. Weekly narrative summaries are generated automatically by Gemini 1.5 Pro using roleplay transcripts, chat logs, and admin logs. These summaries are grounded through a RAG pipeline backed by NotebookLM Plus, ensuring that all synthesized content matches established lore.  
The interface represents this timeline as a scrollable, vertical thread of illuminated parchment nodes. Users can tap individual nodes to view expanded summaries, browse active global factions, and view character relationships that update dynamically as the chronicle progresses.

## **Module 2: Technical Requirement Document (TRD)**

### **Data and Knowledge Layer**

#### **Scaffolding Google Sheets Access**

The portal's data engine connects to the community’s Google Sheets backend using the official googleapis package for Dart, with authorization managed via googleapis\_auth. Client applications are restricted to read-only scopes, while administrative actions run through a service account to secure backend operations.  
`import 'dart:convert';`  
`import 'package:googleapis/sheets/v4.dart';`  
`import 'package:googleapis_auth/auth_io.dart';`

`class GoogleSheetsDataEngine {`  
  `final String spreads[span_31](start_span)[span_31](end_span)[span_37](start_span)[span_37](end_span)heetId;`  
  `final String _base64ServiceAccountKey;`  
  `SheetsApi? _sheetsApi;`

  `GoogleSheetsDataEngine({`  
    `required this.spreadsheetId,`  
    `required String serviceAccountKey,`  
  `}) : _base64ServiceAccountKey = serviceAccountKey;`

  `Future<void> initializeEngine() async {`  
    `final decodedKey = utf8.decode(base64.decode(_base64ServiceAccountKey));`  
    `final credentials = ServiceAccountCredentials.fromJson(json.decode(decodedKey));`  
    `final scopes = [SheetsApi.spreadsheetsScope];`  
      
    `final client = await clientViaServiceAccount(credentials, scopes);`  
    `_sheetsApi = SheetsApi(client);`  
  `}`

  `Future<ValueRange> readSheetRange(String range) async {`  
    `if (_sheetsApi == null) {`  
      `throw StateError('Google Sheets Data Engine must be initialized prior to execution.');`  
    `}`  
    `return await _sheetsApi!.spreadsheets.values.get(spreadsheetId, range);`  
  `}`

  `Future<UpdateValuesResponse> appendRow(String range, List<List<Object>> values) async {`  
    `if (_sheetsApi == null) {`  
      `throw StateError('Google Sheets Data Engine must be initialized prior to execution.');`  
    `}`  
    `final valueRange = ValueRange()..values = values;`  
    `return await _sheetsApi!.spreadsheets.values.update(`  
      `valueRange,`  
      `spreadsheetId,`  
      `range,`  
      `valueInputOption: 'USER_ENTERED',`  
    `);`  
  `}`  
`}`

#### **Open Knowledge Framework and Grounded RAG Pipeline**

The NotebookLM Enterprise API focuses on notebook lifecycle and metadata management. It does not expose programmatically accessible endpoints to query internal vector indexes or execute real-time, grounded RAG operations.  
`+---------------------------------------------------------------------------------+`  
`|                          GROUNDED RAG PIPELINE WORKFLOW                         |`  
`|                                                                                 |`  
`|  +--------------------------+                 +------------------------------+  |`  
`|  |   Google Sheets Roster   |                 |      Lore Document Repository |  |`  
`|  |    (Rosters & Logs)      |                 |       (Rulebooks & History)  |  |`  
`|  +--------------------------+                 +------------------------------+  |`  
`|                |                                              |                 |`  
`|                +-----------------------+----------------------+                 |`  
`|                                        | Ingest & Standardize                 |`  
`|                                        v                                        |`  
`|                       +----------------------------------+                      |`  
`|                       |   Markdown Conversion Parser     |                      |`  
`|                       |  (OCR Correction & Table Format) |                      |`  
`|                       +----------------------------------+                      |`  
`|                                        |                                        |`  
`|                                        v                                        |`  
`|                       +----------------------------------+                      |`  
`|                       |      Gemini 1.5 Pro API          |                      |`  
`|                       | (2M Token Context Window Cache)  |                      |`  
`|                       +----------------------------------+                      |`  
`|                                        |                                        |`  
`|                                        +----------------------------------------+`  
`|                                        | Grounded Context                       |`  
`|                                        v                                        |`  
`|                       +----------------------------------+                      |`  
`|                       |       DeepSeek-V4-Pro API        |                      |`  
`|                       |   (Structure & Lore Audit)       |                      |`  
`|                       +----------------------------------+                      |`  
`|                                        |                                        |`  
`|                                        v                                        |`  
`|                       +----------------------------------+                      |`  
`|                       |  Grounded Verification Output    |                      |`  
`|                       +----------------------------------+                      |`  
`+---------------------------------------------------------------------------------+`

To bridge this operational gap and maintain a highly precise evaluation engine, the architecture implements a custom, long-context ingestion pipeline:

1. **Source Synchronization and Parsing**: A background synchronization script pulls unstructured documents from the community Google Drive and Sheets repositories. It converts this data into structured Markdown files, cleaning up text issues and formatting tables specifically for LLM readability.  
2. **Context Ingestion and Caching**: This structured Markdown database is fed directly into the context window of a programmatic Gemini 1.5 Pro instance using the Google AI Studio SDK, utilizing context caching to optimize performance.  
3. **Reasoning Grounding**: When an administrative evaluation is triggered, DeepSeek-V4-Pro queries this programmatic Gemini instance. The model cross-references the candidate's input against the grounded knowledge base, identifying lore conflicts, chronological anomalies, or character overlaps.

### **Multi-Model AI Service Layer**

To optimize performance across different use cases, AI tasks are categorized by complexity, speed requirements, and cognitive depth, and then routed to the most appropriate model.  
`+---------------------------------------------------------------------------------+`  
`|                       MULTI-MODEL ROUTING ARCHITECTURE                          |`  
`|                                                                                 |`  
`|                        +---------------------------+                            |`  
`|                        |  Incoming Client Request  |                            |`  
`|                        +---------------------------+                            |`  
`|                                      |                                          |`  
`|                                      v                                          |`  
`|                        +---------------------------+                            |`  
`|                        |   AI Dispatch Router      |                            |`  
`|                        +---------------------------+                            |`  
`|                                      |                                          |`  
`|         +----------------------------+----------------------------+             |`  
`|         | < 200ms Latency            | Deep Reasoning             | Narrative   |`  
`|         v                            v                            v             |`  
`|  +--------------+             +--------------+             +--------------+     |`  
`|  |   Groq API   |             |   DeepSeek   |             |  Gemini Pro  |     |`  
`|  | (Llama-3-70B)|             |  (V4-Pro)    |             |  (1.5-Pro)   |     |`  
`|  +--------------+             +--------------+             +--------------+     |`  
`|  | Real-Time    |             | Complex Lore |             | Weekly Log   |     |`  
`|  | Tone Checks  |             | Compliance   |             | Chronicle    |     |`  
`|  | & Validation |             | Evaluation   |             | Synthesis    |     |`  
`|  +--------------+             +--------------+             +--------------+     |`  
`+---------------------------------------------------------------------------------+`

The orchestration engine routes tasks dynamically using dedicated API gateways:

* **The Real-Time Evaluation Gateway**: Powered by Groq, this gateway handles fast tasks like evaluating text lengths, filtering vulgarity, and checking for missing input fields during the initial application phase. Processing latency is strictly capped to keep UI interactions smooth and responsive:

\\text{Latency} \< 200\\text{ ms}

* **The Reasoning Audit Gateway**: Directed to DeepSeek-V4-Pro, this gateway handles deep checks on submitted applications, comparing the user's input against canonical records to identify lore conflicts or character discrepancies.  
* **The Chronicle Generation Gateway**: Powered by Gemini 1.5 Pro, this gateway leverages massive context windows to process and synthesize weekly chat transcripts and update faction data tables.

### **Vibe Coding Pipeline**

The interface is built using a "Vibe Coding" workflow, translating visual design concepts into functional Dart code using Google Stitch and the Antigravity CLI (\[span\_52\](start\_span)\[span\_52\](end\_span)agy).  
`+---------------------------------------------------------------------------------+`  
`|                             VIBE CODING MCP WORKFLOW                            |`  
`|                                                                                 |`  
`|  +-------------------------+                 +-------------------------------+  |`  
`|  |      Google Stitch      |                 |        Antigravity CLI        |  |`  
`|  |   (Visual UI Design)    |                 |         (agy Engine)          |  |`  
`|  +-------------------------+                 +-------------------------------+  |`  
`|               |                                              |                  |`  
`|               | Design Tokens                                | Generates        |`  
`|               v                                              v                  |`  
`|  +-------------------------+                 +-------------------------------+  |`  
`|  |       Stitch MCP        | --------------> |       Project Workspace       |  |`  
`|  |  (extract_design_context)|                 |          (AGENTS.md)          |  |`  
`|  +-------------------------+                 +-------------------------------+  |`  
`|                                                              |                  |`  
`|                                                              v                  |`  
`|                                              +-------------------------------+  |`  
`|                                              |   Dart & Flutter MCP Server   |  |`  
`|                                              |   (Introspects Widget Tree)   |  |`  
`|                                              +-------------------------------+  |`  
`|                                                              |                  |`  
`|                                                              v                  |`  
`|                                              +-------------------------------+  |`  
`|                                              |     Agentic Hot Reload        |  |`  
`|                                              |   (Auto-Update Emulator)      |  |`  
`|                                              +-------------------------------+  |`  
`+---------------------------------------------------------------------------------+`

#### **The Stitch-to-agy MCP Data Flow**

1. **Interface Design in Google Stitch**: UI wireframes and interactive mockups are built in Google Stitch. The platform compiles visual layouts and styling definitions into design tokens and structured JSON metadata rather than flat screenshots.  
2. **Design Context Extraction via MCP**: These design tokens are passed through the Model Context Protocol (MCP) using the stitch-mcp bridge. The tool extract\_design\_context parses the visual workspace to extract typography rules, color schemes, and layout hierarchies, creating a localized DESIGN.md file in the project's root folder.  
3. **Widget Generation with agy**: The Antigravity CLI (agy) ingests DESIGN.md alongside the instructions in AGENTS.md. Developers prompt the agent: agy generate "Build roster screen from design tokens". The Go-based CLI reads the workspace using the Dart and Flutter MCP server and writes clean, feature-based Dart files directly into the project structure.  
4. **Agentic Hot Reload**: The Dart and Flutter MCP server integrates directly with the running application workspace. When agy modifies a Dart widget file, it triggers a hot reload of the Flutter environment, displaying the visual modifications on the running emulator without requiring manual recompilation.

#### **"Stitch Skills \- Loop" Integration Workflow**

To generate multi-screen experiences and maintain code consistency, the development pipeline utilizes the stitch-loop skill. This workflow executes iterative, multi-step generation loops:  
`# Register design-md and stitch-loop skills within the Antigravity workspace`  
`npx skills add google-labs-code/stitch-skills --skill design-md --global`  
`npx skills add google-labs-code/stitch-skills --skill stitch-loop --global`

Once registered, the stitch-loop skill automates page transitions, validates widgets, and checks code accuracy. The agent evaluates the DESIGN.md guidelines, generates the screen structures, and runs flutter analyze via the MCP pipeline to capture and correct syntax issues before saving.

### **State Management, Responsiveness, and Mobile Security**

#### **State Architecture with Riverpod Notifier**

Application state is managed using the Riverpod library, ensuring that modifications to characters, roster records, or world states propagate immediately to active views. Riverpod providers isolate data operations from the visual layout, using asynchronous and reactive pathways to prevent blocking the UI thread during computational operations:  
`import 'package:riverpod_annotation/riverpod_annotation.dart';`  
`import 'package:supabase_flutter/supabase_flutter.dart';`

`part 'admittance_provider.g.dart';`

`@riverpod`  
`class AdmittancePipelineController extends _$AdmittancePipelineController {`  
  `final _supabase = Supabase.instance.client;`

  `@override`  
  `Future<List<Map<String, dynamic>>> build() async {`  
    `final response = await _supabase`  
        `.from('applications')`  
        `.select()`  
        `.eq('status', 'pending');`  
    `return List<Map<String, dynamic>>.from(response);`  
  `}`

  `Future<void> submitDecision(String applicationId, String decision, String reason) async {`  
    `state = const AsyncValue.loading();`  
    `try {`  
      `await _supabase.from('applications').update({`  
        `'status': decision,`  
        `'moderator_notes': reason,`  
        `'reviewed_at': DateTime.now().toIso8601String(),`  
      `}).eq('id', applicationId);`  
        
      `ref.invalidateSelf();`  
    `} catch (e, stack) {`  
      `state = AsyncValue.error(e, stack);`  
    `}`  
  `}`  
`}`

#### **Responsive Viewport Adaptation**

Layouts adapt in real time using a dynamic ResponsiveLayout helper. This widget leverages the rendering container's constraints to switch between mobile and desktop structures without causing layout overflows or forcing hard reloads.  
`import 'package:flutter/material.dart';`

`class AdaptiveCardGrid extends StatelessWidget {`  
  `final List<Map<String, dynamic>> characters;`

  `const AdaptiveCardGrid({Key? key, required this.characters}) : super(key: key);`

  `@override`  
  `Widget build(BuildContext context) {`  
    `return LayoutBuilder(`  
      `builder: (context,[span_59](start_span)[span_59](end_span) constraints) {`  
        `if (constraints.maxWidth < 600) {`  
          `return ListView.builder(`  
            `itemCount: characters.length,`  
            `itemBuilder: (context, index) {`  
              `return Card(`  
                `child: ListTile(`  
                  `title: Text(characters[index]['name']),`  
                  `subtitle: Text(characters[index]['house']),`  
                `),`  
              `);`  
            `},`  
          `);`  
        `} else {`  
          `return GridView.builder(`  
            `gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(`  
              `crossAxisCount: 3,`  
              `childAspectRatio: 1.5,`  
            `),`  
            `itemCount: characters.length,`  
            `itemBuilder: (context, index) {`  
              `return Card(`  
                `child: Center(`  
                  `child: Text(characters[index]['name']),`  
                `),`  
              `);`  
            `},`  
          `);`  
        `}`  
      `},`  
    `);`  
  `}`  
`}`

#### **Security Boundaries and Mobile Deep Linking**

Administrative control panels are protected behind strict security layers. Public player screens run with low-privilege read-only permissions. Admin sections require full multi-factor credentials and authorized access tokens managed via Supabase Row-Level Security (RLS) policies.  
Passwordless Magic Links are used to streamline mobile logins, bypassing traditional form entries. When a user requests login, Supabase generates and emails a secure access link containing a transactional token hash. Clicking this link triggers native deep-link mapping to redirect the user back to the portal.

* **Android App Links Setup (AndroidManifest.xml)**: The manifest defines intent filters to catch verification links from the web domain, allowing the system to open the application automatically when links are tapped.

`<intent-filter android:autoVerify="true">`  
    `<action android:name="android.intent.action.VIEW" />`  
    `<category android:name="android.category.DEFAULT" />`  
    `<category android:name="android.category.BROWSABLE" />`  
    `<data android:scheme="https" />`  
    `<data android:host="theremainderportal.com" />`  
    `<data android:pathPrefix="/login-callback" />`  
`</intent-filter>`

* **iOS Universal Links Setup (Runner.entitlements)**: Similarly, the entitlement manifest registers the associated domain mapping to associate the application with the web verification endpoints.

`<key>com.apple.developer.associated-domains</key>`  
`<array>`  
    `<string>applinks:theremainderportal.com</string>`  
`</array>`

## **Module 3: Next-Gen and Agentic Tools Comparison Report**

### **Autonomous Agent Code Generation Dynamics**

Building software with autonomous agents like the Antigravity CLI (agy) differs fundamentally from manual engineering workflows. Instead of coding line-by-line, the developer acts as an editor and systems orchestrator, setting architectural rules and defining programmatic guardrails.  
To prevent logic drift, maintain architectural structure, and avoid code regression across multiple platforms, several programmatic guardrails are enforced:

* **Structural Isolation with AGENTS.md**: Placed at the project's root folder, this file serves as the system's "AI Constitution". It instructs the agent on specific coding style guidelines, state management choices (e.g., *only Riverpod with AsyncNotifier, no legacy FutureProviders*), folder boundaries, and layout standards.  
* **Linter and Static Analysis Enforcement**: The model cannot commit changes to the active codebase without first running local static analysis:

`flutter analyze && flutter test`

If these tools return compilation errors, formatting issues, or test failures, the model must roll back its edits, diagnose the failures, and refit the widgets to meet compilation standards.

* **Dry-Run Validations**: The agy pipeline runs multi-file modifications in separate, sandboxed buffers. This ensures that changes are validated and approved before being merged into the primary production branch.

### **Terminal-First CLI vs. Agentic IDE Workspaces**

Evaluating the developer workspace requires analyzing the tradeoffs between terminal-first CLI agents and integrated visual IDE workspaces.

| Workspace Attribute | Antigravity CLI (agy) | Full Agentic IDE Workspace |
| :---- | :---- | :---- |
| **User Interface Paradigm** | Terminal-first interactive TUI console | Desktop visual interface, multi-pane editors |
| **System Footprint & Overhead** | Low, optimized for lightweight terminal execution | Moderate to High, requires graphical rendering resources |
| **Contextual Awareness** | Evaluates code structures via the workspace directories | Visual access to screen hierarchies and emulator run states |
| **Development Speed** | High speed, ideal for scripting and automation commands | Interactive editing, best for manual visual tweaks |
| **MCP Integration Hook** | Command-line parameters and skill definitions | Interactive configuration panels and server managers |

### **CI/CD and Automated Distribution Workflow**

To automate builds, testing, and deployment across multiple platforms, the system uses Harness CI, orchestrating compilation and code-signing for iOS, Android, and Web targets.

#### **Keystore Ingestion and Android Code-Signing Build**

The Android build pipeline compiles and signs release binaries (.aab files) automatically. Keystore files and passwords are base64-encoded and stored as secure environment variables, which are injected dynamically during execution to prevent credentials from being exposed in source control.  
`# Partial Harness CI Stage Configuration for Android Targets`  
`- step:`  
    `name: Setup Android Code Signing`  
    `identifier: android_signing`  
    `type: Run`  
    `spec:`  
      `shell: Bash`  
      `command: |`  
        `echo "Retrieving base64-encoded release keystore file"`  
        `echo <+secrets.getValue("ANDROID_KEYSTORE_BASE64")> | base64 -d > android/app/release.keystore`  
          
        `echo "Configuring build.properties metadata files"`  
        `cat <<EOF > android/key.properties`  
        `storePassword=<+secrets.getValue("ANDROID_KEYSTORE_PASSWORD")>`  
        `keyPassword=<+secrets.getValue("ANDROID_KEY_PASSWORD")>`  
        `keyAlias=<+secrets.getValue("ANDROID_KEY_ALIAS")>`  
        `storeFile=release.keystore`  
        `EOF`  
          
        `flutter build appbundle --release`

#### **Provisoning Profiles and iOS Code-Signing Build**

The iOS build pipeline requires secure access to App Store Connect certificates and provisioning profiles. Fastlane Match is used to fetch and update these assets automatically, storing certificates in a secure, private repository.  
`# Partial Harness CI Stage Configuration for iOS Targets`  
`- step:`  
    `name: Build and Sign iOS Binary`  
    `identifier: ios_signing`  
    `type: Run`  
    `spec:`  
      `shell: Bash`  
      `command: |`  
        `# Setup App Store Connect API keys`  
        `export APPLE_API_KEY_ISSUER_ID=<+secrets.getValue("APPLE_API_KEY_ISSUER_ID")>`  
        `export APPLE_API_KEY_ID=<+secrets.getValue("APPLE_API_KEY_ID")>`  
        `echo <+secrets.getValue("APPLE_API_KEY_CONTENT_BASE64")> | base64 -d > ios/api-key.p8`  
          
        `# Pull matching profile records`  
        `cd ios && bundle exec fastlane match appstore --readonly`  
          
        `# Build and export final production .ipa binary package`  
        `cd .. && flutter build ipa --release --export-options-plist=ios/ExportOptions.plist`

#### **Static Compilation and Web Deployment**

The web build pipeline compiles the application assets and deploys them directly to static CDN environments.  
`# Partial Harness CI Stage Configuration for Web Targets`  
`- step:`  
    `name: Compile and Deploy Web Target`  
    `identifier: web_deploy`  
    `type: Run`  
    `spec:`  
      `shell: Bash`  
      `command: |`  
        `# Build static HTML and Javascript dependencies`  
        `flutter build web --release --web-renderer canvaskit`  
          
        `# Deploy built assets to static hosting CDN`  
        `firebase deploy --only hosting --token <+secrets.getValue("FIREBASE_CLI_TOKEN")>`

### **Backend Scaling and Integration Matrix**

Choosing the right data tier requires analyzing the trade-offs of using Google Sheets compared to modern database alternatives.

| Operational Criterion | Legacy Google Sheets | NocoDB (Self-Hosted) | Supabase (Managed Postgres) |
| :---- | :---- | :---- | :---- |
| **API Limit Thresholds** | 300 requests/minute (strict throttling) | CPU-bound server constraints | Scales dynamically, capable of handling thousands of requests/second |
| *Data Integrity & Typings* | None, cells accept any text or value type | Basic type checks on front-end fields | Highly strict, database-level schema enforcement |
| **Security & Permissions** | All-or-nothing folder/file sharing | Basic role-based access rules | Fine-grained, real-time Row-Level Security (RLS) |
| **Real-Time Data Streaming** | Polling required, high latency | Polling or basic webhook signals | Native Postgres real-time listeners and broadcasts |
| **OKF & RAG Pipeline Ingestion** | Simple reads, but prone to rate limits during bulk scans | Easy JSON exports over structured models | Direct vector searches, pgvector index compatibility |
| **Development Setup** | Extremely simple, no deployment needed | Requires Docker or server instances | Simple cloud configuration with full developer tooling |

#### **Causal Analysis and Architectural Recommendations**

The evaluation confirms that while Google Sheets works well as a simple tabular backend for small communities, it introduces significant technical bottlenecks under modern application workloads:

1. **API Throttling Vulnerability**: The Google Sheets API enforces a strict limit of 300 requests per minute. In an active multi-model AI pipeline, parallel queries from DeepSeek-V4-Pro, Groq, and Gemini will quickly exhaust this limit, causing service interruptions.  
2. **Lack of Type Enforcement**: The absence of strict data validation in Google Sheets allows invalid or malformed data to be saved to the database. This can break structural parsing logic in the Flutter application and lead to unhandled runtime errors.  
3. **Security Inefficiencies**: Managing table access and protecting player privacy requires writing complex, custom validation rules within the application code, rather than managing them securely at the database level.

Therefore, migrating data to Supabase (Managed Postgres) is highly recommended for production environments. Transitioning to Supabase provides built-in Row-Level Security (RLS), scales to handle high-throughput workloads, and provides a stable database layer with native support for relational queries, real-time events, and AI vector search capabilities.

## **Strategic Synthesis and Implementation Roadmap**

To transition The Remainder Portal from a visual concept to a functional cross-platform application, development is structured across three core phases:  
`+---------------------------------------------------------------------------------+`  
`|                            IMPLEMENTATION TIMELINE                              |`  
`|                                                                                 |`  
`|  +---------------------------+  Configure   +--------------------------------+  |`  
`|  |         Phase 1           | -----------> | Design Core Visual Framework,  |  |`  
`|  |     (Base System Setup)   |              | Establish Roster Sheets & Dev  |  |`  
`|  +---------------------------+              +--------------------------------+  |`  
`|               |                                              |                  |`  
`|               | Progresses                                   | Iterates         |`  
`|               v                                              v                  |`  
`|  +---------------------------+  Integrate   +--------------------------------+  |`  
`|  |         Phase 2           | -----------> | Configure Multi-Model Router,  |  |`  
`|  |      (Agentic & AI)       |              | Connect RAG with Gemini        |  |`  
`|  +---------------------------+              +--------------------------------+  |`  
`|               |                                              |                  |`  
`|               | Finalizes                                    | Tests            |`  
`|               v                                              v                  |`  
`|  +---------------------------+  Deploy      +--------------------------------+  |`  
`|  |         Phase 3           | -----------> | Setup Harness Pipelines,       |  |`  
`|  |      (Deployment)         |              | Universal Links, Prod Run      |  |`  
`|  +---------------------------+              +--------------------------------+  |`  
`+---------------------------------------------------------------------------------+`

### **Phase 1: Base System Setup and Visual Framework**

* Initialize the local developer environment, configure the initial dependencies inside pubspec.yaml, and write the code guidelines in AGENTS.md.  
* Use Google Stitch to design the UI screens, then export the visual properties through the stitch-mcp connector to create DESIGN.md in the workspace.  
* Build the core frosted glassmorphic widgets and adaptive layout containers using agy, leveraging the Dart & Flutter MCP server to verify scaling in the emulator.  
* Establish secure read connections to the community’s Google Sheets repository to load active player and roster records.

### **Phase 2: Orchestration and Grounded RAG Integration**

* Set up the multi-model AI routing manager, utilizing Groq API for rapid text validations and DeepSeek-V4-Pro for deep reasoning checks.  
* Address the NotebookLM Enterprise API querying limitations by implementing a custom parsing script. This script converts canonical documents into structured Markdown, loading the text directly into a programmatic Gemini 1.5 Pro instance via Google AI Studio.  
* Ground the evaluation engine in this knowledge base, enabling DeepSeek-V4-Pro to cross-reference applicant submissions against verified lore documents.  
* Run the custom stitch-loop skill to generate details screens, navigation paths, and administrative panels.

### **Phase 3: Authentication, Distribution, and Production Deployments**

* Configure Supabase authentication, using Magic Links to handle user logins securely on mobile devices.  
* Create and host verification files (apple-app-site-association and assetlinks.json) on the web domain, and register deep-linking patterns in iOS and Android configurations.  
* Configure the Harness CI pipeline using native macOS runners to manage Fastlane Match credentials, compile signed .ipa and .aab packages, and distribute releases to testers. \* Run a progressive migration of legacy community data from Google Sheets to a managed Supabase Postgres instance, enabling Row-Level Security policies and native database-level validation.

#### **Works cited**

1\. flutter\_glass\_morphism | Flutter package \- Pub.dev, https://pub.dev/packages/flutter\_glass\_morphism 2\. Pushing Flutter's UI aesthetics: A designer's take on Glassmorphism and KPI widgets : r/FlutterDev \- Reddit, https://www.reddit.com/r/FlutterDev/comments/1sl45ix/pushing\_flutters\_ui\_aesthetics\_a\_designers\_take/ 3\. material\_palette | Flutter package \- Pub.dev, https://pub.dev/packages/material\_palette 4\. Top Flutter Glassmorphic UI, Glass UI, Glassmorphism, Acrylic material packages | Flutter Gems, https://fluttergems.dev/glassmorphic-ui/ 5\. Top Flutter Background Effects, Gradients & Shaders packages, https://fluttergems.dev/effects-gradients-shaders/ 6\. Implementing Glassmorphism Effects in Flutter UIs \- Vibe Studio, https://vibe-studio.ai/insights/implementing-glassmorphism-effects-in-flutter-uis 7\. 12 Glassmorphism UI Features, Best Practices, and Examples \- UX Pilot, https://uxpilot.ai/blogs/glassmorphism-ui 8\. Writing and using fragment shaders \- Flutter documentation, https://docs.flutter.dev/ui/design/graphics/fragment-shaders 9\. How to Read Google Sheet Data in a Flutter App \- Voxturrlabs, https://voxturrlabs.com/blog/how-to-read-google-sheet-data-in-flutter-app/ 10\. Supabase vs Google Sheets: Why SMEs Are Migrating in 2026 \- BOVO Digital, https://www.bovo-digital.tech/en/blog/supabase-vs-google-sheets-automation-mistake 11\. CI/CD in Flutter: Automate, Build, Deploy Like a Pro | by Nithin TA | Medium, https://medium.com/@codernta/ci-cd-in-flutter-automate-build-deploy-like-a-pro-ba4e81f141ca 12\. How to Read Google Sheet Data in a Flutter App \- GeekyAnts, https://geekyants.com/blog/how-to-read-google-sheet-data-in-a-flutter-app 13\. supabase\_flutter | Flutter package \- Pub.dev, https://pub.dev/packages/supabase\_flutter 14\. Architecting the Future of Research: A Technical Deep-Dive into NotebookLM and Gemini Integration \- DEV Community, https://dev.to/jubinsoni/architecting-the-future-of-research-a-technical-deep-dive-into-notebooklm-and-gemini-integration-m60 15\. Flutter Google Sheets \- Dart API docs \- Pub.dev, https://pub.dev/documentation/google\_sheets/latest/ 16\. Google APIs \- Flutter documentation, https://docs.flutter.dev/data-and-backend/google-apis 17\. Create and manage notebooks (API) | NotebookLM Enterprise | Google Cloud Documentation, https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks 18\. NotebookLM Enterprise API: Missing Query/Chat Endpoint for RAG Orchestration \- Agents, https://discuss.google.dev/t/notebooklm-enterprise-api-missing-query-chat-endpoint-for-rag-orchestration/366875 19\. Understanding NotebookLM Enterprise APIs for Programmatic RAG Access \- Reddit, https://www.reddit.com/r/notebooklm/comments/1to8j0v/understanding\_notebooklm\_enterprise\_apis\_for/ 20\. Why is NotebookLM so much better than my custom RAG? (And how do I replicate it via API?) \- Reddit, https://www.reddit.com/r/notebooklm/comments/1rvgdmm/why\_is\_notebooklm\_so\_much\_better\_than\_my\_custom/ 21\. From Notes to Agents: Using NotebookLM with Google AI Studio (and Python) \- Medium, https://medium.com/@bravekjh/from-notes-to-agents-using-notebooklm-with-google-ai-studio-and-python-33145a8b9637 22\. Antigravity 2.0 for Flutter Developers: CLI, SDK & Agentic Workflows That Actually Matter, https://dev.to/sayed\_ali\_alkamel/antigravity-20-for-flutter-developers-cli-sdk-agentic-workflows-that-actually-matter-231o 23\. Design-to-Code with Antigravity and Stitch MCP \- Codelabs, https://codelabs.developers.google.com/design-to-code-with-antigravity-stitch 24\. Great-looking UIs with Google Stitch and Google Antigravity \- Medium, https://medium.com/google-cloud/great-looking-uis-with-google-stitch-and-google-antigravity-88255c97f291 25\. The "Designer Flow" for AI: Why I Built a Bridge to Google Stitch \- MCP \- DEV Community, https://dev.to/kargatharaaakash/the-designer-flow-for-ai-why-i-built-a-bridge-to-google-stitch-423k 26\. Antigravity CLI \- Flutter documentation, https://docs.flutter.dev/ai/antigravity-cli 27\. Create with AI \- Flutter documentation, https://docs.flutter.dev/ai/create-with-ai 28\. From Prompt to Product: Investigating AI-Driven Web Design with Antigravity \+ Stitch, https://scuti.asia/from-prompt-to-product-investigating-ai-driven-web-design-with-antigravity-stitch/ 29\. Use Supabase with Flutter, https://supabase.com/docs/guides/getting-started/quickstarts/flutter 30\. Build a User Management App with Flutter | Supabase Docs, https://supabase.com/docs/guides/getting-started/tutorials/with-flutter 31\. Native Mobile Deep Linking | Supabase Docs, https://supabase.com/docs/guides/auth/native-mobile-deep-linking 32\. Flutter Deep Linking: Complete Guide for Android App Links & iOS Universal Links, https://dev.to/ankushppie/flutter-deep-linking-complete-guide-for-android-app-links-ios-universal-links-4kde 33\. Set up universal links for iOS \- Flutter documentation, https://docs.flutter.dev/cookbook/navigation/set-up-universal-links 34\. The Stitch Skills AntiGravity Integration That's Changing AI Development Forever, https://juliangoldie.com/stitch-skills-antigravity-integration/ 35\. How to Build a Complete Flutter CI/CD Pipeline with Codemagic: From PR Quality Gates to Automated Store Releases \- freeCodeCamp, https://www.freecodecamp.org/news/build-a-complete-flutter-ci-cd-pipeline-with-codemagic/ 36\. Getting Started with Google Antigravity \- Codelabs, https://codelabs.developers.google.com/getting-started-google-antigravity 37\. Optimizing mobile app development with DevSecOps and CI/CD \- Harness, https://www.harness.io/blog/mobile-devsecops 38\. Tutorial \- React Native and iOS pipeline \- Harness Developer Hub, https://developer.harness.io/docs/continuous-integration/development-guides/mobile/e2e-ios-tutorial 39\. Flutter CI/CD & Code Signing — Complete Reference Guide (Fastlane, Codemagic, Shorebird, GitHub Actions), https://gist.github.com/ravidsrk/0a6a53c2a1fc8e1a18cc1eda9e0b9bc2 40\. Flutter CI/CD with Codemagic Part 1: Automating test releases \- Polymorph Systems, https://polymorph.co.za/software-engineering-and-technology/automating-test-releases-for-mobile-app-development-with-codemagic/ 41\. How to use AI Agent Skills (with Antigravity CLI and Agent Skills for Firebase) \- Codelabs, https://codelabs.developers.google.com/antigravity/how-to-create-agent-skills-for-antigravity-cli 42\. Understanding pubspec.yaml: Managing Dependencies | by Harsh Kumar Khatri \- Medium, https://mailharshkhatri.medium.com/understanding-pubspec-yaml-managing-dependencies-8b8de16b5c3c