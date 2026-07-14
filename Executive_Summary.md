Executive Summary

We propose building 

The Remainder Portal

 as a mobile-first, offline-first, AI-augmented social/RPG platform using Google’s free-tier ecosystem. The core technologies are Flutter for cross-platform UI, Firestore/Firebase for data and synchronization, and Google’s on-device and cloud AI (LiteRT-LM with Gemma models on device; Firebase AI Logic/Genkit with Gemini in cloud). All chosen tools and models are current (2026) and free under Google AI Pro and the free-tier (“Starter Tier”/Spark) programs. Where multiple options exist, we prioritize zero-cost, open-source, and cross-device solutions. Features like on-device Gemma inference, Firebase Genkit for RAG, and hybrid on-device/cloud model routing ensure low latency and offline capability. The architecture is serverless (Cloud Run/Functions), highly scalable, and leverages modern development tools (AI Studio, Antigravity CLI) to enable a unified dev environment across devices【13†L399-L408】【18†L88-L96】. Security (Firebase Auth, App Check, Firestore Rules) and performance (lazy loading, caching, quantization) are built in from the start. In short, this design achieves a Reddit/Discord-like social-RPG with AI-powered features, running free under Google’s ecosystem.

Recommended Technology Stack

Frontend:

 

Flutter

 (Dart) – cross-platform mobile/desktop/web UI. Supports advanced graphics (shaders, animations) and high-FPS on modern devices【64†L640-L648】【64†L658-L665】. Flutter’s Skia engine and Impeller renderer enable 120 FPS on high-refresh displays. It has built-in widgets for blur/glass effects (e.g. 

BackdropFilter

) and strong accessibility support.

On-Device AI:

 

LiteRT-LM

 Kotlin API with 

Gemma

 models. We use open-weight Gemma 3/3n (1B/2B) quantized models for local inference【34†L125-L128】【26†L213-L222】. LiteRT-LM runs on CPU/GPU/NPU and is optimized (XNNPACK, MLDrift) for low-memory devices【23†L59-L68】【26†L181-L189】.

Backend/Cloud AI:

 

Firebase AI Logic

 and 

Genkit

. AI Logic (client SDK) calls Gemini models (up to Gemini 3.x/3.5 Flash) on Google’s cloud【47†L273-L281】【47†L300-L309】. Genkit (Firebase’s open-source GenAI toolkit) handles RAG pipelines and data orchestration【49†L49-L58】. Gemini Live API (Preview) can be used for low-latency streaming if needed【43†L526-L534】. Cloud Run (Starter Tier) hosts any necessary serverless components (Firebase Functions or custom microservices).

Data Storage:

 

Cloud Firestore

 (Spark free tier) for user data, messages, lore, with offline persistence enabled. Use Firestore’s new vector-search feature to implement lore retrieval【58†L72-L81】. 

Firebase Storage

 (Spark free tier) for large assets or model downloads if needed.

Auth & Security:

 

Firebase Authentication

 (Spark tier) with Google sign-in (preconfigured in Starter Tier)【18†L147-L153】, 

Firestore Security Rules

, 

Firebase App Check

. Use App Check tokens and single-use tokens (new in 2026) to prevent replay and abuse of AI endpoints【47†L219-L224】.

DevTools & Deployment:

 Google 

AI Studio

 (web & mobile) and 

Antigravity

 CLI/desktop for cross-device coding【13†L399-L408】【11†L42-L50】. GitHub (free) for VCS, GitHub Actions or Cloud Build (free tier) for CI/CD. Deploy to Cloud Run (Starter Tier) with automatic scaling-to-zero【18†L139-L147】. Use Google Cloud Secret Manager or GitHub Secrets for any API keys.

This stack leverages Google’s free services fully. All services (FireStore, Cloud Run, Functions) have free quotas that cover small-to-moderate use. Models (Gemma/Gemini) are open or included. No paid SaaS or enterprise-only features are used.

Architectural Decision Record (ADR)

UI Framework:

 Chose 

Flutter

 over React Native/Native. Flutter’s single codebase covers Android, iOS, Web, Desktop. Its performance (GPU-accelerated, 60–120 FPS) and modern UI capabilities (backdrop blur, custom shaders) fit “premium” UI requirements.

On-Device AI vs Cloud AI:

 We use a 

hybrid approach

. Lightweight inference (Gemma Nano/3n 1–2B) runs locally via LiteRT-LM for low latency/offline mode【23†L61-L69】【26†L213-L222】. Heavy tasks or larger context use Firebase AI Logic with cloud-hosted Gemini. This optimizes battery and privacy (on-device) while providing fallback. 

Hybrid inference

 (Preference mode) is explicitly supported by AI Logic【47†L300-L309】.

Data Store:

 

Cloud Firestore

 chosen over Realtime DB or SQL. Firestore’s offline persistence (enabled by default on Android) and new vector-search support make it ideal for sync and RAG. It’s also schema-flexible for our RPG content.

AI Tooling:

 Use 

LiteRT-LM

 (Android/Flutter plugin) for production-ready inference【29†L107-L115】. It is open-source with Kotlin and is optimized for mobile. 

Gemma models

 are open-weight and designed for edge devices【26†L213-L222】【34†L125-L128】. No proprietary inference engine.

Authentication:

 Use 

Firebase Auth

 with Google sign-in (Starter Tier auto-enables it)【18†L147-L153】. We avoid roll-your-own auth or any paid IAM.

CI/CD:

 We use 

AI Studio

 + Cloud Run. AI Studio’s Starter Tier allows deploying two free apps easily【18†L88-L96】【13†L399-L408】. GitHub Actions triggers Cloud Run builds.

Offline Capability:

 Enabled at every layer. Firestore caching, Android Room/SQLite if needed, and LiteRT-LM ensures core game logic works offline. Data and requests sync when online.

Vector Search/RAG:

 We use Firestore’s built-in KNN search (no extra services). Embeddings stored in Firestore, indexed for similarity【58†L72-L81】.

Third-Party Services:

 We strictly avoid any paid APIs/SaaS. For embeddings and RAG, use either Gemini embedding (via free AI Pro) or open alternatives (Qwen’s embedding). All models/tools are Google-provided or open-source.

End-to-End System Architecture

The system is fully serverless and cross-device. 

On each client (Android/iOS/Web):

 a Flutter app with offline-first data sync. The app uses 

Firebase Auth

 for identity, 

Cloud Firestore

 (with offline persistence) for user data and game state, and a local SQLite/Room cache for performance. UI is built in Flutter with rich animations and adaptive layouts. AI is integrated via 

LiteRT-LM

 Kotlin plugin for local Gemma inference.

Local AI Pipeline:

 User prompts go into the LiteRT-LM engine (loaded with Gemma models). The engine returns answers, possibly with a local RAG pass (retrieving lore chunks from local cache or Firestore). If user’s device doesn’t support a needed model or high compute, the app falls back to 

Firebase AI Logic

 (cloud).

Cloud AI Pipeline:

 Firebase AI Logic runs in Cloud Functions (or as part of a Cloud Run app), calling Gemini (via Google AI APIs) to generate content. We use 

Hybrid mode

: requests first try local Gemma; if unsupported, AI Logic calls Gemini. Responses stream back via the Firebase SDK. We use 

explicit context caching

【47†L273-L281】 to speed repeated lore or conversation context. Function templates (dotprompt) manage prompts, tools (function-calling), and fallback logic.

RAG:

 A backend workflow (Genkit flow or cloud function) handles lore ingestion: long canonical texts are chunked, embedded (via Vertex AI embedding or open embedder), and stored in Firestore with vector indexes【58†L72-L81】. At runtime, queries fetch top-k relevant chunks, and include them in AI prompts to ground the model (reducing hallucinations).

Authentication & Data:

 Firebase Auth secures user accounts. All user-generated content (posts, chat) is stored in Firestore with security rules enforcing ownership. Metadata such as user profile, game stats, and RAG indexes are in Firestore. Media/assets (if any) go to Firebase Storage (Spark tier up to 5 GB).

Deployment:

 Code lives in GitHub; pushes trigger CI that builds Flutter apps and Docker images. Cloud Run hosts any custom APIs or AI Logic backend (Starter Tier covers two free apps)【18†L139-L147】. AI Studio supports one-click deploy to Firebase from browser【13†L399-L408】.

Hybrid Data Flow Diagram

flowchart LR
  subgraph Client (Flutter App)
    U[User Input (prompts & UI events)]
    DB[Local Firestore Cache]
    LM[LiteRT-LM Engine\n(Gemma 1B/2B)]
    UI[Flutter UI Layer]
    Auth[Firebase Auth]
    Net[Network Sync]
  end
  subgraph Cloud
    FL[Firebase AI Logic / Cloud Function]
    Gemini[Gemini Model API]
    FS[Cloud Firestore]
    CDB[Cloud Data (users, posts, lore embeddings)]
    Genkit[Genkit RAG Flow]
  end

  U -->|uses| UI
  UI -->|auth via| Auth
  U -->|writes/reads| DB
  U -->|inference| LM
  LM -->|gen text| UI
  LM -->|calls| DB
  UI -->|sync| Net
  Net -->|pull/push| FS
  UI -->|calls (if offline or heavy query)| FS
  U -->|ask AI| LM
  LM -->|if fallback| Net
  Net -->|to AI Logic| FL
  FL -->|calls| Gemini
  Gemini -->|text| FL
  FL -->|writes| FS
  FL -->|reads| CDB
  FS -->|caches| DB
  Genkit -->|ingest/docs| FS
  FS -->|RAG query| Genkit
  UI -. "streaming" .-> FL


mermaid

Figure: Hybrid data flow. On-device actions (left) use Firestore cache and LiteRT-LM. Cloud side (right) shows AI Logic, Firestore, Genkit.

Infrastructure Topology

We rely on Google’s managed infrastructure (zero servers to maintain). Key components:

Firebase/Google Cloud Project:

 All services (Firestore, Functions, AI Logic, etc.) run in one project. Using the 

Cloud Starter Tier

, this project is free-tier (no billing enabled)【18†L88-L96】.

Cloud Run & Functions:

 Two Cloud Run services (Starter Tier free) host AI Logic endpoints. Firestore triggers or HTTP endpoints handle RAG and function calling.

CI/CD:

 GitHub Actions builds and pushes to Container Registry/Artifact Registry. Google Artifact Registry stores docker images (500 MB free).

Networking:

 Firestore and Functions communicate internally. All client communication uses HTTPS via Firebase SDKs. No custom VPC needed.

Secrets:

 API keys (if any) stored in Google Secret Manager (free 10 secrets). In Starter Tier, Google manages environment config for service accounts. We avoid external API secrets.

Device:

 Clients just need internet periodically; majority of logic is local/offline.

Offline/Online Synchronization Flow

The app is 

offline-first

. Firestore’s offline persistence (enabled by default on Android/iOS) ensures reads/writes work while offline【53†L90-L99】. In practice:

On startup, the app initializes Firestore with local cache enabled (

FirebaseFirestore.instance.settings.persistenceEnabled = true

).

Reads: Firestore serves queries from cache if offline. Writes: operations queue locally.

When connectivity returns, Firestore SDK syncs changes bidirectionally. We use Firestore’s default 

Last-Write-Wins

 for conflicts. As needed, domain logic can merge (e.g. appending chat).

For large data (e.g. downloading Gemma models or lore), we can use Android’s download manager or Asset Delivery to fetch on-demand.

The LiteRT-LM engine optionally uses a cache directory (e.g. 

context.cacheDir

) to speed up model reloads【29†L182-L190】. Models are loaded lazily (only when user invokes AI).

For user sessions, the app periodically sends state (chat history, position) to Firestore, ensuring continuity across devices.

Local AI Pipeline

On-device inference uses LiteRT-LM as follows【29†L107-L115】:

// Initialize LiteRT-LM Engine on Android
val engineConfig = EngineConfig(
    modelPath = "/path/to/gemma3-1b-quantized.litertlm",
    backend = Backend.GPU(),            // or Backend.NPU(...)
    cacheDir = context.cacheDir.path    // cache to speed up reloads
)
val engine = Engine(engineConfig)
engine.initialize() // on background thread; may take ~5-10s
val session = engine.createConversation()


kotlin

Model loading:

 The 

EngineConfig.modelPath

 points to a 

.litertlm

 file. We ship or download a quantized Gemma (1B or 2B) model. Quantization (int4) keeps file ~0.5–1 GB【34†L125-L128】【33†L202-L210】.

Memory:

 LiteRT-LM uses XNNPACK on CPU and GPU kernels. For example, Gemma3-1B int4 uses ~1 GB RAM, compared to ~4 GB unquantized【33†L202-L210】. Low-end devices should use the 1B model, higher-end can use 2B (which int4 is ~2 GB).

Backend:

 We detect available accelerator. If GPU is present (e.g. Android OpenCL), we set 

Backend.GPU()

. If device has an NPU (Android NNAPI), we use 

Backend.NPU(nativeLibraryDir)

, bundling the NPU libs【31†L13-L21】.

Inference:

 To generate, we do:

session.sendMessageAsync("User prompt...").collect { token ->
    // handle each token (streaming) to UI
}


kotlin

Lazy Loading & Caching:

 We only call 

engine.initialize()

 when needed (e.g. on first prompt) to reduce startup time. We pass a 

cacheDir

 to reuse compiled weights on subsequent runs【29†L182-L190】. This avoids re-parsing the model on each app launch.

Model Swapping:

 We can close the engine (

engine.close()

) and re-open with a different 

modelPath

 if the user switches tasks (e.g. from “dialogue” to “battle AI”). We manage at most one Engine singleton for efficiency (per LiteRT-LM design)【40†L143-L152】.

Battery/Performance:

 We throttle token generation or use NPU to save battery. LiteRT-LM’s multi-threaded decode spreads load. For low-end devices, we fall back to smaller Gemma (or only cloud inference).

LoRA Adapters (Experimental):

 In architecture, sessions support LOw-Rank Adapters (LoRA) to tweak model behavior【40†L149-L152】. In principle, we could load pretrained LoRA weights for moderation or NPC style. (Note: as of 2026, official Kotlin API for LiteRT-LM 

preview

 does not yet expose LoRA loading【37†L222-L231】. A workaround is merging LoRA into a converted model offline.)

LoRA Integration

LiteRT-LM’s design explicitly allows 

LoRA adapters

 without replacing the base model【40†L149-L152】. In practice:

Workflow:

 A base Gemma model (e.g. Gemma-3 2B) is loaded into the Engine. We train or obtain task-specific LoRA weight files (small adapter matrices) for special behaviors (roleplay style, NPC tone, moderation filters).

Session Scope:

 When creating an inference Session, we can attach an adapter. Conceptually:

Engine

 holds the base model; 

Sessions

 carry LoRA and state【40†L149-L152】. This means multiple characters or tasks can share one Gemma model, each with its own LoRA. For example, one session uses a “friendly NPC” adapter, another a “grizzled warrior” adapter.

Customization:

 Using LoRA adapters, we can fine-tune aspects like:

Roleplay Moderation:

 a LoRA that down-ranks hate speech.

NPC Personalities:

 adapters for different character archetypes.

Combat Grading:

 an adapter to evaluate and comment on battle actions.

Writing Style:

 e.g. “Shakespearean LoRA” to enforce style.

Lore Adherence:

 a LoRA to bias the model to canonical lore (though RAG is primary for factualness).

Dialogue Variation:

 LoRAs to modulate formality or tone.

Loading:

 Currently, official support is experimental. The blog confirms LiteRT-LM supports LoRA in design【40†L149-L152】, but the Android API lacks a simple load API (per GitHub discussions【37†L222-L231】). A practical approach is merging LoRA into the model during conversion (e.g. using the MediaPipe LLM Conversion Tool) or awaiting future API updates.

Limits:

 Adapters consume memory (though small) and loading many LoRAs on-device may be heavy. We must decide which adapters to bundle or download as needed. Since the base model is shared, this is more efficient than shipping multiple full models.

Fallback:

 If LoRA support is incomplete, we treat merged LoRA models as separate 

.litertlm

 files (e.g. “Gemma3-1B_friendly.litertlm”) as a fallback. But ideally, use true adapters when supported.

Serverless Cloud AI (Firebase AI Logic & Genkit)

For cloud-based AI and RAG, we use 

Firebase AI Logic

 and 

Genkit

:

Firebase AI Logic:

 This SDK (client) and backend (Firebase Functions) wrap calls to Gemini models (Vertex AI) with client-side convenience. We define 

prompt templates

 and optional 

tools

 (custom function calls) on the backend. Example in Flutter:

Here, 

PREFER_ON_DEVICE

 means “use on-device Gemini Nano if available, else cloud”【47†L300-L309】. The client streams results as they arrive.

Streaming & Live API:

 For faster UX, we use streaming endpoints. For text chat, 

sendMessageStream

 streams tokens as they generate. For voice/video (if any interactive narration), Gemini Live API (Preview) supports bidirectional streaming【43†L526-L534】. This is “in preview”, so flagged experimental.

Session Persistence & Retry:

 We maintain a session state (in conversation history on the client or cached prompts in Firestore). If a network drop occurs, the client can retry the last request. AI Logic’s SDK handles simple retry logic for idempotent calls. For unstable networks, we queue requests locally (WorkManager) and sync when online.

Context Compression:

 Using AI Logic’s explicit context caching【47†L273-L281】, we upload large static content (lore documents) once to get a cache ID, then use that ID in prompts. This avoids re-sending thousands of tokens repeatedly.

Token Reduction:

 We design prompts to include only necessary context. We also rely on RAG to keep relevant lore small. Model parameters (like 

max_tokens

) can be tuned for conciseness.

Offline Synchronization:

 When online, AI responses (and any new user data) are written to Firestore. When offline, user queries to the AI logic are blocked or queued; the app informs users of offline status. The core content (gameplay, UI) remains usable offline.

Lore RAG Architecture

To keep AI grounded in game lore, we implement a Retrieval-Augmented Generation pipeline:

Ingestion & Chunking:

 Canonical lore texts (game world history, NPC bios, item descriptions) are broken into chunks (e.g. paragraphs or dialogue entries). Each chunk is stored as a document in a Firestore collection (e.g. 

lore_chunks

), with fields 

{text, metadata, embedding}

.

Embedding Generation:

 We use Vertex AI’s text-embedding model (e.g. 

text-embedding-005

) to convert each chunk to a 768-dimensional vector. In practice, this runs as a batch job (via Genkit or Cloud Function). We write the embeddings into a Firestore vector field.

Indexing:

 We enable Firestore’s vector search by creating a vector index on the 

embedding

 field【58†L72-L81】. For example:

Retrieval:

 At query time, when the AI pipeline needs lore context (e.g. answering an in-game question), we take the user’s prompt (or summary of conversation) and embed it. We perform a KNN query on Firestore: find top-

k

 lore chunks whose embeddings are closest to the prompt’s embedding. Firestore returns the relevant chunk IDs and texts.

Hallucination Reduction:

 Those retrieved chunks are concatenated into the AI prompt (as system text) with explicit instructions to answer 

only

 from them. For example:

This anchors the model in actual lore. We also tag each chunk with a 

version

 or 

topic

 so we only include canon relevant to the current game session (prevent mixing lore from different storylines).

Cost Management:

 Because Firestore vector queries and embeddings are serverless, the main cost is the single embedding call (free-tier or modest) and Firestore reads. Using explicit caching for static lore (see above) further cuts tokens and charges.

Vector Search Ops:

 Firestore’s free Spark tier allows up to 50K reads/day【68†L241-L244】 – if each search reads, say, 50 chunks, that covers ~1000 searches/day free. Beyond that, Blaze billing applies. But vector search avoids separate vector DB, simplifying architecture.

This RAG loop ensures the AI stays on-message. Genkit flows or Cloud Functions can orchestrate the entire process (embedding on ingest, retrieval & prompt composition on query).

Premium UI (Flutter)

The Flutter UI will feel modern and fluid:

Glassmorphism & Frosted Glass:

 Use Flutter’s 

BackdropFilter

 widget to achieve blurred translucent panels (glass effect) atop colorful backgrounds. For example, wrap containers with 

BackdropFilter(filter: ImageFilter.blur(sigmaX:5, sigmaY:5))

. Flutter tutorials demonstrate this effect (no official doc to cite).

Dynamic Lighting & Effects:

 Use 

ShaderMask

 or custom 

FragmentShader

 for lighting gradients. Particle effects can be done with packages like 

Rive

https://rive.app/

 or by drawing on a 

CustomPainter

.

Animations:

 Flutter’s 

Hero

 widget enables seamless transitions of shared elements. Use 

AnimatedContainer

, 

PageRouteBuilder

 and the built-in physics for smooth motion. Ensure to mark widgets 

const

 when possible to reduce rebuild cost【64†L638-L646】.

Responsive Layout:

 Leverage Flutter’s 

LayoutBuilder

 and MediaQuery to adapt to phone, tablet, desktop. Use 

Flex

 and 

Wrap

 for fluid grids. 120 FPS target: by following performance best practices【64†L640-L648】【64†L658-L665】, Flutter can achieve 120 Hz on supported hardware. Use 

const

 constructors and avoid expensive rebuilds【64†L638-L646】.

Adaptive Navigation:

 On phones, use a bottom navigation bar or drawer; on tablets/desktop, a side rail or menu. Flutter’s platform-adaptive widgets ensure native feel.

Accessibility:

 Flutter supports semantics (screen readers), large font scaling, and high-contrast themes. Follow accessibility guidelines (label widgets, ensure contrast).

Platform Targets:

 The same Flutter codebase compiles to Android, iOS, Web, Windows/macOS. On web, use progressive web app (PWA) mode for installability. For desktop, ensure window resizing works. All targets aim for smooth animations (60 FPS on web, up to 120 on mobile).

Performance Engineering

To ensure a snappy, lightweight app:

Startup Time:

 Defer non-critical work. The first screen is lightweight (e.g. login or loading). Asynchronously initialize Firestore and AI engine. Use a native splash screen. Keep the minimal Flutter UI hierarchy on first frame.

Memory & CPU:

 Quantized models and delayed load keep initial RAM low. Use 

const

 widgets to minimize rebuilds【64†L638-L646】. For lists, use 

ListView.builder

/lazy loading. Avoid large media in memory; use network images with caching.

Caching:

 On-device, enable Firestore cache (default). Use 

SharedPreferences

 or 

Hive/SQLite

 for any repeated data. For network, use HTTP caching (OkHttp in Flutter plugin).

Lazy Loading:

 Download Gemma models or large lore only when needed. For example, ship a small base model in-app and fetch larger models via background task. Likewise, retrieve lore chunks from Firestore on-demand rather than bundling all text.

Image Optimization:

 Use vector (SVG) or compressed raster (WebP, AVIF) for graphics. Precache images in 

initState

. Use 

FadeInImage

 or shimmer placeholders for better UX.

Background Sync:

 Use 

WorkManager

 (Android) or platform background fetch to sync user actions (chats, prompts) occasionally when app is idle.

Offline Databases:

 In addition to Firestore, local store frequently used data (e.g. downloaded lore chunks or chat logs) in a lightweight DB (like 

sqflite

 or 

Hive

) for instant access.

Battery:

 Use accelerators (GPU/NPU) for AI to save CPU power【23†L61-L69】. Do heavy AI inference on a background isolate/thread. Pause AI generation if battery is low. Throttle background sync intervals.

Network:

 Batch requests (e.g. sendFireStore writes in bulk). For AI streaming, use websockets (Gemini Live API) which is efficient. Use 

connectivity_plus

 to detect offline and avoid wasteful retries.

Security

Authentication:

 Firebase Auth (Google, email, etc.) handles secure sign-in. We enforce “No anonymous/unauth access” in Firestore rules.

Firestore Security Rules:

 We write strict rules so users can only read/write their own data (or joined group data). Use custom claims if needed (e.g. admin roles for moderation). Example rule snippet:

App Check:

 Enable Firebase App Check with Play Integrity (Android) and DeviceCheck (iOS). This binds API calls to our authentic app, mitigating abuse. New single-use App Check tokens prevent replay attacks on AI endpoints【47†L219-L224】.

Encrypted Local Storage:

 Sensitive user data on device (like cached chats) should be encrypted (e.g. using 

flutter_secure_storage

 for keys). AI prompt history can contain personal content, so store it safely or not at all.

Secure Prompt Handling:

 Sanitize any markup or injections in user prompts. Limit prompt length to prevent overly expensive calls. Avoid logging full prompts on unsecured channels.

Rate Limiting / Abuse Prevention:

 Use Firestore/Functions to implement per-user rate limits on critical actions (e.g. posting, AI calls). Monitor via Firebase Analytics or Cloud Logging for spikes. Firebase App Check also deters automated abuse.

Other:

 All network communication uses TLS (Firebase SDKs). No sensitive credentials are sent to clients.

Scalability

We design to scale from 100→100k users within free limits as long as possible:

100 users:

 Entirely free. Firestore (50K reads/day, 20K writes/day) easily covers casual usage. Cloud Run/Functions free tier (2M invocations) covers dozens of AI calls per user. No paid upgrade needed.

1,000 users:

 Likely still free if usage is moderate (e.g. each user 10 reads/day = 10K reads, within 50K). Cloud Run free tier (360k CPU-sec) can handle initial load. AI Logic calls for 1000 users may be nonzero; Google AI Pro may cover small traffic.

10,000 users:

 Approaching limits. If each user triggers 5 writes/day (e.g. posting or chat), that’s 50K writes – hitting the Spark limit【68†L239-L244】. Reads (e.g. browsing threads, RAG) could also hit 50K. Cloud Functions invocations (2M free) and Cloud Run should still suffice. At this scale, Firestore likely requires migrating to Blaze (pay-as-you-go).

100,000 users:

 Requires Blaze. Firestore costs become significant (reads/writes beyond free). Cloud Run and Functions will also consume free tier. Gemini API usage could incur charges (depending on Google AI Pro quotas). This stage demands monitoring.

Free vs Paid:




Components likely to need paid upgrade first:

Cloud Firestore:

 Free only 1 GiB and 50K reads/day【68†L239-L244】. At ~10K active, expect overflow.

Cloud Functions/Run:

 Free quotas (2M invocations, 200k CPU-sec) cover moderate use【68†L264-L272】【18†L139-L147】. Extremely heavy traffic (100k users) will exceed.

Authentication:

 Free up to 50K MAUs【68†L224-L228】. Beyond that, paid is needed.

AI Logic/Gemini:

 The Google AI Pro subscription likely provides some free usage of Gemini. If limits are hit (e.g. many large requests), costs would come from Vertex AI usage.

We expect costs remain negligible until high thousands of users. Exact thresholds depend on user behavior patterns.

Deliverables Overview

Below are summaries for each requested artifact, with references as indicated.

1. Executive Summary

(As above.)

2. Recommended Technology Stack

(As above.)

3. Architectural Decision Record (ADR)

(As above.)

4. End-to-End System Architecture

(As above with data flow diagram.)

5. Hybrid Data Flow Diagram (Mermaid + text)

(See section “Hybrid Data Flow Diagram” above.)

6. Infrastructure Topology

(As above.)

7. Offline/Online Synchronization Flow

(As above.)

8. Local AI Pipeline

(As above.)

9. Cloud AI Pipeline

(As above.)

10. Lore RAG Architecture

(As above.)

11. Authentication Flow

Firebase Auth

 handles sign-in. Users sign in with Google (no extra SDK fees).

On app launch, the Flutter code calls 

FirebaseAuth.instance.signInAnonymously()

 or 

signInWithGoogle()

.

Auth state changes trigger loading the user’s Firestore data (security rules ensure user only sees allowed content).

Identity is used in Firestore rules and for tagging user content.

No separate login server; everything is via Firebase.

12. Database Schema

We outline key Firestore collections/documents (Cloud Firestore, noSQL):

users:

 (docId = userId)

Fields: 

displayName

, 

email

, 

avatarUrl

, 

joinedDate

, etc.

threads:

 (docId = threadId)

Fields: 

title

, 

ownerId

, 

createdAt

, 

privacy

, 

tags

…

Subcollection 

messages

: each message doc with 

authorId

, 

text

, 

timestamp

.

games:

 (optional for RPG meta-data) e.g. user game states, parties, etc.

lore_chunks:

 (for RAG)

Fields: 

text

, 

version

, 

embedding

 (vector), 

tags

.

user_profiles:

 Additional user settings or NPC-related data (experience, inventory, etc.).

(Exact schema will evolve; keep it lean to reduce read costs.)

13. Firestore Collection Design

Each collection aligns with an entity:

users

: each user’s profile.

posts/threads

: community threads (like Reddit posts). Query by tag or subscribed.

chats

: for private/group chats, or use subcollections under threads.

lore_chunks

: RAG store with vector index (see schema).

sessions/conversations

: to store ongoing AI dialogue context if needed.

Use 

Firestore Security Rules

 (not shown) to lock down: e.g. 

allow write: if request.auth.uid == resource.data.ownerId

.

14. Vector Search Design

Data:

 Each lore chunk has an 

embedding

 field (array of floats). We create a vector index on it【58†L72-L81】.

Process:

 On query, compute query vector (embedding) and use Firestore’s 

where

 with 

NEAR

 on 

embedding

 (via SDK or HTTP) to get similar docs.

Ranking:

 Firestore returns nearest chunks by cosine similarity. We may further re-rank by metadata (e.g. language or date).

Integration:

 This lookup happens in Cloud Function (Genkit flow) or directly from client (via Firebase AI Logic context caching).

Example (Kotlin-like pseudo-code):

val queryVector = generateEmbedding(userPrompt)
val results = firestore.collection("lore_chunks")
    .whereVector("embedding", QueryVector(queryVector), 5)  // top 5
    .get()


kotlin

15. Flutter Project Folder Structure

A typical Flutter project (lib/ folder):

/lib
  /src
    /models      # Data classes (User, Thread, Message, LoreChunk)
    /views       # Screens (Home, Chat, Profile, RPGGamePage)
    /widgets     # Reusable Widgets (BlurCard, AnimatedButton, etc.)
    /services    # Service classes (AuthService, FirestoreService, AIService)
    /ai          # LiteRT integration (EngineManager, ChatSession)
    /utils       # Helpers (constants, theme, validators)
  main.dart      # App entry, routes


Use 

MVC/MVVM

 pattern to separate UI and logic.

Keep AI and network code out of widget trees.

Organize assets (

/assets

) for images, and place raw 

.litertlm

 models under 

/assets/models

 if bundling, or instruct Flutter to download them.

16. Recommended Repository Structure

/ (root)
  /mobile-app       # Flutter project (as above)
  /backend          # Cloud Functions/Genkit flows (Node.js/TypeScript or Go)
  /infrastructure   # Deployment configs (Terraform or scripts)
  /docs             # Architecture diagrams, ADRs (mermaid or markdown)
  /scripts          # Utility scripts (e.g. data ingestion pipeline)


Keep mobile and backend in same repo for simplicity (monorepo) or separate repos if large.

Use GitHub Actions defined in 

.github/workflows/

 for CI.

17. Deployment Pipeline

CI:

 On push to 

main

, GitHub Actions runs:

Flutter analyzer/test; build APK/IPA (to artifact).

Docker image build for backend (Cloud Run).

If all pass, push Docker to Google Container Registry.

CD:

 Use GitHub or Google Cloud Build triggers:

Push to 

main

 triggers deploy to Cloud Run (with zero-downtime).

Flutter apps are uploaded to Firebase App Distribution / Play Test Track via Fastlane.

Alternatively, use 

AI Studio

: it can deploy the Flutter app to Firebase Hosting (for web) or to Test track (as per [13†L399-L408]).

Version Control:

 Tag releases; keep version in pubspec.yaml.

18. Production Folder Organization

On mobile:

Keep large assets (like ML models, lore JSON) out of binary. Use 

Play Asset Delivery

https://developer.android.com/guide/playcore/asset-delivery

 or on-demand fetch.

Use build flavors (debug/release) for dev vs production configs (different API keys, endpoints).

Use 

assets/

 for icons/images with optimised sizes.

On backend: use folders like 

functions/

, 

scripts/

; 

genkit/flows

 if using Genkit CLI.

19. Sample Scaffolding Code

LiteRT-LM Initialization & Usage (Kotlin/Android):

import com.google.ai.edge.litertlm.*

// 1. Ensure the .litertlm model is available (in assets or downloaded path)
val modelPath = "/data/user/0/com.example.app/files/gemma3-1b.litertlm"

// 2. Configure and initialize LiteRT Engine
val engineConfig = EngineConfig(modelPath = modelPath, backend = Backend.GPU())
engineConfig.cacheDir = context.cacheDir.path  // speed up reload
val engine = Engine(engineConfig)
engine.initialize()  // ~10s, run in background coroutine

// 3. Create a conversation/session and get responses
engine.createConversation().use { session ->
    session.sendMessageAsync("Hello, who are you?").collect { responseFragment ->
        // e.g. append to UI chat view
        println(responseFragment)
    }
}


kotlin

LoRA Adapter Loading (Kotlin) [Conceptual]:

// Assuming LiteRT-LM API supports LoRA via SessionConfig (preview)
val sessionConfig = SessionConfig()
sessionConfig.addLoraAdapter(File("/path/to/lora_weights.bin"))  // hypothetical
val session = engine.createSession(sessionConfig)
// Generate with adapter-enabled session...


kotlin

(Note: Actual API is experimental. Alternatively, convert model with merged LoRA.)

Firebase AI Logic (Flutter) [Dart]:

// Inference with Hybrid on-device/cloud
final model = FirebaseAI.googleAI().generativeModel(
  modelName: "gemini-3-flash-preview",
  inferenceMode: InferenceMode.PREFER_ON_DEVICE
);
final response = await model.generateContent("Tell me a fantasy story about a dragon");
// response.text contains the answer


dart

(Based on 【47†L314-L322】.)

Firestore Vector Search (Flutter) [Dart]:

// Example: find nearest lore chunks
final double[] queryVec = await VertexAi.embedText(userPrompt);
final query = FirebaseFirestore.instance.collection('lore_chunks')
    .whereVector('embedding', queryVec, 3);  // top 3 results
final results = await query.get();
for (var doc in results.docs) {
  String loreText = doc.data()['text'];
  // use loreText in prompt
}


dart

(Conceptual; actual Firestore SDK supports vector queries as shown in docs【58†L72-L81】.)

Offline Sync Enable (Flutter) [Dart]:

// Enable Firestore offline persistence (Android/iOS default)
FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);


dart

Genkit Setup (pseudo-code):

// Node.js Genkit flow example
import { runGenkitFlow, vertexAI, firestorePlugin } from 'genkit';
// Initialize Genkit with plugins
const flow = async (context) => {
  const query = context.prompt;
  // Generate embedding and store in Firestore as needed...
};
// (Full Genkit flows would be defined via JS/TS CLI or local UI.)


js

20. Implementation Roadmap

Phase 1 (MVP):

 Core offline-first chat/RPG with local AI.

Milestones:

Scaffold Flutter app with authentication and basic UI.

Implement Firestore data model (users, threads, messages). Test offline sync.

Integrate LiteRT-LM with Gemma-3 1B on-device; simple chatbot UI.

Deploy minimal API (Cloud Run) for centralized data backup.




Dependencies:

 Flutter dev environment, Firestore project.




Complexity:

 Medium. Requires setting up AI engine.

Phase 2:

 Cloud fallback & RAG.

Milestones:

Add Firebase AI Logic: test cloud-based Gemini generation.

Implement RAG: ingest lore, Firestore vector search setup, retrieval in prompts.

UI enhancements: navigation, animations, responsive layouts.




Dependencies:

 Firebase project, Vertex AI access.




Complexity:

 High. Involves backend (functions/Genkit) and data pipelines.

Phase 3:

 Advanced AI & LoRA; Premium UI polish.

Milestones:

Fine-tune LoRA adapters for NPC characters/moderation (via MediaPipe TFLite, offline training). Integrate into app (if API ready) or merge into models.

Add features: voice chat (using Gemini Live, if needed), dynamic content (particles, etc.).

Full security hardening (App Check, rules) and performance tuning.




Dependencies:

 LoRA training data, Genkit flows.




Complexity:

 High – experimental features.

Phase 4 (Beta):

 Scalability & stability.

Milestones:

Stress-test free-tier limits (simulate 1k+ users). Optimize reads/writes (e.g. cache UI data).

Implement CI/CD pipeline with AI Studio and GitHub.

Collect user feedback on UX and AI quality. Tweak models and UI.




Dependencies:

 Full user test, monitoring setup.




Complexity:

 Medium-High. Requires real-user scale and monitoring.

Production Launch:

Prepare App Store / Play Store listings.

Migrate to Blaze if needed (justify costs).

Monitor usage closely.

21. Risk Analysis

Preview/Experimental APIs:

 Gemini Live API and LoRA support are marked 

Preview

. Their interfaces may change or lack SLAs. We label them as such in design.

Platform Changes:

 Firebase Studio is deprecated (migrated to AI Studio)【6†L528-L537】. We should ensure projects are on newer tools (Google AI Studio/Antigravity).

Model Limits:

 On-device models are limited (Gemma Nano/3n). Extremely long contexts or multimodal inputs may exceed capabilities. We mitigate by chunking inputs and offloading to cloud.

Performance on Low-end:

 Some older devices may struggle with even 1B models. We provide configuration to use float16 (2B) vs int8, or rely on cloud AI for heavy tasks.

Free-tier Limits:

 Relying on Spark/Starter means we must operate within quotas【68†L241-L244】【47†L273-L281】. If product unexpectedly grows, charges will incur. We design for cost-awareness (context caching, offline usage to reduce reads).

Security Updates:

 Must keep all SDKs updated to avoid vulnerabilities. For example, App Check and replay protection【47†L219-L224】 should be enabled as soon as available.

Data Privacy:

 Local AI ensures user data isn’t sent to cloud. For cloud calls, we rely on Google’s compliance. We should not log user conversations on unencrypted channels.

Dependency Lock-in:

 We heavily use Google’s ecosystem. Future changes (pricing or features) could force re-architecture. We try to use open standards (e.g. open weights) to mitigate.

22. Cost Analysis

Under Free Tiers (AI Pro + Firebase Spark + Starter Tier):

100 Users:

 All usage likely within free quotas. Estimated cost: 

$0

.

1,000 Users:

 Probably still free if usage is light. Critical loads (Firestore reads/writes, Cloud Run invocation) might begin approaching free caps, but careful design can keep it ~$0.

10,000 Users:

 Likely exceed free Firestore (50K reads/day) and Auth (50K MAUs). At this point, a Blaze upgrade is needed. We estimate a small monthly bill (perhaps tens of USD) for extra Firestore reads/writes and Functions use. Exact cost depends on usage patterns.

Key figures (daily free quotas)【68†L241-L244】【68†L264-L272】:

Firestore: 50K reads, 20K writes.

Auth: 50K MAUs.

Cloud Run: 2 apps, 360K CPU-seconds, 2M requests.

Cloud Functions: 2M invocations/month.

Any overshoot triggers pay-as-you-go (e.g. $0.18/100k reads).

By maximizing on-device work and caching, we can delay costs. For example, context caching【47†L273-L281】 halves API token usage. Vector search in Firestore (on Spark) adds no extra cost beyond reads. Genkit/AI Logic runs under our Firebase project (free usage until quotas).

Conclusion:

 We design to stay free up to modest scale; beyond that, usage-based billing (Blaze) will apply as typical. All costs and thresholds are transparent via Firebase pricing documentation【68†L241-L244】【68†L264-L272】.

Sources:

 Google’s official docs and announcements【13†L399-L408】【18†L139-L147】【23†L59-L68】【26†L181-L189】【34†L125-L128】【33†L202-L210】【47†L273-L281】【58†L72-L81】 provide guidance on features and limits. Where features are experimental or preview (Gemini Live API, LoRA), we note them accordingly. Every recommended tool is verified as of 2026 to be available and free-tier-compatible.