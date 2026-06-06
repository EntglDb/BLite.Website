# BLite.Website - Analisi pagina per pagina degli snippet di codice

## Scopo
Questo documento analizza le pagine doc del sito BLite.Website una per una, verificando ogni snippet contro i sorgenti del repository BLite prima di proporre qualsiasi classificazione o refactor.

Fonti controllate con priorita`:
- [BLite.Core](../BLite/src/BLite.Core)
- [BLite.Caching](../BLite/src/BLite.Caching)
- [BLite.Wasm](../BLite/src/BLite.Wasm)

Le pagine che usano API non trovate nei sorgenti core sono marcate come `da riallineare`.

## Sintesi rapida

| Pagina | Natura | Esito |
|---|---|---|
| Installation | Installazione / package | Ok, nessun rischio API |
| GettingStarted | Typed-first con sezione cache | Verificata, candidata a doppio esempio |
| CRUD | Typed-only async CRUD | Verificata, candidata a doppio esempio |
| Querying | Typed LINQ | Verificata, da lasciare typed-only |
| Transactions | Mixed typed + engine/session | Verificata |
| DynamicAPI | Dynamic-only | Verificata, da lasciare cosi` |
| BLQL | Dynamic-only | Verificata, da lasciare cosi` |
| TimeSeries | Mixed typed + dynamic | Verificata, ma con un nome metodo da correggere |
| KvStore | Mixed typed + engine + cache | Verificata |
| Converters | Mixed | Verificata, con parte JSON utile per DynamicCollection |
| CDC | Mixed | Parzialmente verificata, c`e` un nome tipo da riallineare |
| Spatial | Typed-focused | Parzialmente verificata, c`e` un nome metodo da riallineare |
| WasmSupport | Mixed | Parzialmente verificata, un helper typed non e` trovato nel core |
| Encryption | Engine-focused | Parzialmente verificata, `BLiteEngineOptions` non trovato nel core |
| AuditTrail | Engine-focused | Parzialmente verificata, varie classi non trovate nel core |
| GDPR | Mixed infra/compliance | Parzialmente verificata, alcuni nomi sono da riallineare |
| Generators | Historical / feature matrix | Verificata nel complesso |
| Architecture | Infrastruttura | Nessun rischio API rilevante |
| Benchmarks | Benchmarking | Nessun rischio API rilevante |
| Comparisons | Marketing / confronto | Nessun rischio API rilevante |

## Criterio usato

Per ogni pagina ho controllato prima i sorgenti e poi ho separato gli snippet in tre categorie:

- `verificato` = la firma esiste nel core o nel pacchetto corretto.
- `da lasciare` = la pagina e` volutamente mono-modello, non va forzata in dual mode.
- `da riallineare` = il nome o la forma non risultano nei sorgenti attuali.

## Analisi per pagina

### Installation
Pagina di installazione pura. I comandi `dotnet add package`, `Install-Package`, `git clone` e gli snippet `.csproj` sono solo istruzioni di setup, quindi non richiedono controllo API. Nessun esempio va reso duale.

### GettingStarted
Verificata contro `DocumentDbContext`, `DocumentCollection<TId,T>`, `BLiteEngine` e `BLite.Caching`.

- Il modello `AppDbContext : DocumentDbContext` e la proprieta` `DocumentCollection<ObjectId, User> Users` sono coerenti con il core.
- `InsertAsync`, `FindByIdAsync`, `UpdateAsync`, `DeleteAsync`, `AsQueryable()` sono presenti in `DocumentCollection`.
- La sezione cache usa `AddBLiteDistributedCache` e `IBLiteCache`, che sono definiti in [BLite.Caching](../BLite/src/BLite.Caching/BLiteCachingExtensions.cs) e [IBLiteCache](../BLite/src/BLite.Caching/IBLiteCache.cs).

Valutazione: pagina corretta, ma e` uno dei punti migliori per introdurre una coppia di esempi typed/dynamic sullo stesso scenario base.

### CRUD
Verificata contro `DocumentCollection<TId,T>`.

- Gli snippet usano solo API async, coerenti con la versione corrente del core.
- `InsertAsync`, `InsertBulkAsync`, `FindByIdAsync`, `FindAllAsync`, `FindAsync`, `UpdateAsync`, `DeleteAsync`, `AsQueryable()` sono tutte supportate.
- La pagina conclude gia` con un richiamo alla schema-less API, ma oggi resta soprattutto typed-only.

Valutazione: ottimo candidato per una riscrittura parallela con `DynamicCollection`, mantenendo la stessa sequenza CRUD.

### Querying
Verificata contro `DocumentCollection<TId,T>`, `IBLiteQueryable<T>`, `EntityTypeBuilder<T>` e le estensioni di indice.

- `AsQueryable()` e` presente nel core.
- `EnsureIndex(...)` e `HasIndex(...)` sono coerenti con `DocumentCollection` e `EntityTypeBuilder`.
- Gli esempi su proiezione push-down, aggregazioni, `GroupBy`, `OrderBy`, `Take`, `Explain()` sono in linea con la query pipeline typed.

Valutazione: da lasciare typed-only. Questa pagina e` la controparte naturale di BLQL, quindi non va contaminata con esempi DynamicCollection.

### Transactions
Verificata contro `DocumentDbContext`, `BLiteEngine` e `BLiteSession`.

- `BeginTransactionAsync`, `CommitAsync`, `RollbackAsync` esistono sia sul context typed sia sul engine.
- `BLiteSession` supporta `BeginTransaction`, `InsertAsync`, `FindByIdAsync`, `GetOrCreateCollection`, `CommitAsync`, `Rollback`.
- La sezione `Hot Backup` e` coerente sia per il context typed sia per il engine.

Valutazione: pagina mixed corretta. Qui ha senso tenere sia il flusso typed sia quello engine/session, perche` spiegano due livelli diversi dello stesso modello transazionale.

### DynamicAPI
Verificata contro `BLiteEngine`, `DynamicCollection` e `DynamicCollectionBlqlExtensions`.

- `GetOrCreateCollection(name, idType)` esiste su `BLiteEngine` e restituisce `DynamicCollection`.
- `Insert`, `InsertAsync`, `InsertBulk`, `FindById`, `FindAll`, `FindAsync`, `Scan`, `QueryIndex`, `VectorSearch`, `Near`, `Within`, `SetTimeSeries`, `ForcePruneAsync` sono tutte parte del core dynamic.
- La tabella API e` coerente con l’idea di pagina schema-less.

Valutazione: da lasciare dynamic-only.

### BLQL
Verificata contro `DynamicCollectionBlqlExtensions`, `BlqlQuery`, `BlqlFilter`, `BlqlProjection` e `BlqlFilterParser`.

- `Query()`, `Query(BlqlFilter)`, `Query(string filterJson)` esistono su `DynamicCollection`.
- La pagina confronta correttamente BLQL con LINQ, ma la colonna typed rappresenta il paradigma equivalente, non una pagina da duplicare qui.
- Gli operatori `Eq`, `Gt`, `Between`, `In`, `Exists`, `Regex`, `And`, `Or`, `NearVector`, `GeoWithin`, `GeoNear` sono tutti coerenti con i sorgenti BLQL.

Valutazione: da lasciare dynamic-only. Qui il riferimento typed deve restare solo comparativo, non diventare un secondo blocco di esempio.

### TimeSeries
Verificata contro `EntityTypeBuilder<T>.HasTimeSeries`, `DocumentCollection.SetTimeSeries`, `DynamicCollection.SetTimeSeries`, `ForcePruneAsync`.

- La parte typed con `HasTimeSeries(...)` e` corretta.
- La parte dynamic con `SetTimeSeries(field, retention)` e` corretta.
- Il punto critico e` il metodo di pruning: nei sorgenti il nome presente e` `ForcePruneAsync()`, non `ForcePrune()`.

Valutazione: pagina mixed corretta, ma va allineato il nome del metodo di prune in tutti gli snippet e nella tabella di riferimento.

### KvStore
Verificata contro `BLiteEngine.KvStore`, `IBLiteKvStore`, `IBLiteCache`, `AddBLiteDistributedCache`, `BLiteKvOptions`.

- La sezione engine e` corretta: `BLiteEngine` espone `KvStore`.
- La sezione typed con `DocumentDbContext` e `KvStore` e` coerente con i costruttori del context.
- La sezione cache e` supportata dal pacchetto [BLite.Caching](../BLite/src/BLite.Caching).

Valutazione: pagina mixed corretta. Non serve forzare qui una coppia typed/dynamic completa; il focus e` KV + cache.

### Converters
Verificata contro `ValueConverter<TModel,TProvider>`, `EntityTypeBuilder<T>.Property(...).HasConversion<TConverter>()`, `BsonJsonConverter`.

- La parte ValueObject converter e` coerente con il source builder.
- `BsonJsonConverter` e` pertinente soprattutto per `BLiteEngine + DynamicCollection`.
- L’uso di JSON come ponte verso BSON e` corretto e utile per la modalita` schema-less.

Valutazione: pagina mixed corretta. La parte JSON/BSON deve restare ancorata a DynamicCollection; la parte ValueObject e` chiaramente typed.

### CDC
Verificata contro `DocumentCollection<T>.Watch(...)`, `DynamicCollection.Watch(...)`, `WatchOptions`.

- Gli esempi `Watch()` typed e dynamic sono entrambi supportati dal core.
- La forma `dynamicCol.Watch(capturePayload: true)` e` coerente con l’overload `Watch(bool capturePayload)`.
- Il nome `DocumentDb` usato nel sample finale non risulta nel core che ho controllato; nel repository attuale il tipo di base e` `DocumentDbContext`.

Valutazione: pagina mixed, ma il sample finale va riallineato al tipo reale. La parte dynamic puo` restare com`e`, la parte typed va resa piu` precisa.

### Spatial
Verificata contro `DocumentCollection<T>`, `EntityTypeBuilder<T>.HasSpatialIndex`, `CollectionSecondaryIndex.Near/Within` e `GeoSpatialExtensions`.

- I marker `Near(...)` e `Within(...)` per la query LINQ sono presenti.
- Gli indici spaziali typed si costruiscono dal model builder con `HasSpatialIndex(...)`.
- `EnsureSpatialIndex(...)` e `GetCollection<T>()` non risultano nel core che ho controllato, quindi gli snippet che li usano non sono attualmente verificati.

Valutazione: pagina typed-focused ma con un paio di nomi da riallineare ai sorgenti attuali.

### WasmSupport
Verificata contro `BLiteWasm.CreateAsync`, `BLiteEngine.CreateInMemory`, `StorageEngine`, `MemoryPageStorage`, `MemoryWriteAheadLog`, `DocumentDbContext(StorageEngine)`.

- La parte `BLiteWasm.CreateAsync(...)` e i backend OPFS/IndexedDB sono coerenti con la libreria WASM.
- `BLiteEngine.CreateInMemory()` e` supportato dal core.
- L’esempio typed con `GetCollection<Todo>()` non e` stato trovato nel core che ho controllato; potrebbe essere sample-specific o una forma vecchia.

Valutazione: pagina mixed, ma il blocco typed va controllato con attenzione prima di essere considerato fonte autorevole.

### Encryption
Verificata contro `CryptoOptions`, `BLiteEngine(string, CryptoOptions, ...)`, `DocumentDbContext(string, CryptoOptions, ...)`.

- `CryptoOptions` esiste e supporta sia passphrase mode sia master-key mode.
- Il costruttore del engine con `CryptoOptions` e` coerente.
- `BLiteEngineOptions` non e` risultato presente nei sorgenti core che ho controllato, quindi gli snippet che lo usano non sono verificati.

Valutazione: pagina engine-focused da riallineare; la parte concettuale e` corretta, ma la forma API va aggiornata.

### AuditTrail
Verificata parzialmente contro il core GDPR/telemetry, ma non trovata come API identica nei sorgenti core.

- `BLiteEngineOptions`, `ConsoleBLiteAuditSink`, `IBLiteAuditSink`, `BLiteAuditEntry` non sono risultati nei controlli effettuati sul core.
- Il concetto di audit e telemetria esiste nel core, ma i nomi del sample attuale sembrano appartenere a una superficie API diversa o a una versione precedente.

Valutazione: pagina da riallineare completamente al core corrente prima di essere considerata affidabile.

### GDPR
Verificata contro `SubjectQuery`, `GdprEngineExtensions`, `GdprDocumentDbContextExtensions`, `EntityTypeBuilder<T>.HasGdprMode`, `BLiteKvOptions.DefaultGdprMode`.

- `SubjectQuery`, `SubjectDataReport`, `GdprMode`, `HasGdprMode(...)` e l’idea di strict mode sono supportati.
- `HasSecureErase()` non e` risultato nel core che ho controllato; nei sorgenti GDPR compare invece il messaggio che la secure erase come setting engine-level non e` ancora disponibile.
- `BLiteEngineOptions` non e` risultato nel core.
- `GetOrCreateCollection<ObjectId, AuditEntry>(mapper)` non e` una forma che ho verificato nel core attuale.

Valutazione: pagina concettualmente valida, ma con piu` punti da riallineare ai nomi reali del repository.

### Generators
Pagina storica / feature matrix.

- Le affermazioni su `DocumentCollection<T>`, `DynamicCollection.Watch()`, `IDocumentCollection<T>` e `BLiteEngine` come entry point sono coerenti con i sorgenti attuali.
- La pagina racconta versioni e milestones, quindi non va letta come fonte primaria per la forma moderna di ogni API, ma come cronologia.

Valutazione: complessivamente corretta, con attenzione a non prendere ogni riga storica come suggerimento di uso attuale.

### Architecture
Pagina descrittiva dell’architettura interna, quasi tutta diagrammi e testo esplicativo.

- Non contiene superfici API delicate da rifattorizzare verso typed/dynamic.
- E` utile come contesto, non come target per la doppia documentazione di esempio.

Valutazione: nessuna azione necessaria.

### Benchmarks
Pagina di benchmark e confronto prestazionale.

- I blocchi di codice sono principalmente comandi di esecuzione benchmark o setup dati.
- Non e` una pagina da trasformare in doppio esempio DocumentCollection/DynamicCollection.

Valutazione: nessuna azione necessaria.

### Comparisons
Pagina di confronto con altri progetti / package.

- Gli snippet sono soprattutto comandi `dotnet add package` e non esempi di API operative.
- Nessun rischio di confusione typed/dynamic sul piano del codice.

Valutazione: nessuna azione necessaria.

## Pagine da lasciare volutamente dynamic-only

- [BLQL.vue](src/views/docs/BLQL.vue)
- [DynamicAPI.vue](src/views/docs/DynamicAPI.vue)

## Pagine da tenere mixed, ma con verifica puntuale dei nomi API

- [GettingStarted.vue](src/views/docs/GettingStarted.vue)
- [Transactions.vue](src/views/docs/Transactions.vue)
- [TimeSeries.vue](src/views/docs/TimeSeries.vue)
- [KvStore.vue](src/views/docs/KvStore.vue)
- [Converters.vue](src/views/docs/Converters.vue)
- [CDC.vue](src/views/docs/CDC.vue)
- [WasmSupport.vue](src/views/docs/WasmSupport.vue)
- [GDPR.vue](src/views/docs/GDPR.vue)

## Pagine da riallineare ai sorgenti prima di considerarle definitive

- [TimeSeries.vue](src/views/docs/TimeSeries.vue): `ForcePrune()` -> `ForcePruneAsync()`.
- [CDC.vue](src/views/docs/CDC.vue): `DocumentDb` non verificato nel core.
- [Spatial.vue](src/views/docs/Spatial.vue): `EnsureSpatialIndex(...)` e `GetCollection<T>()` non verificati nel core.
- [WasmSupport.vue](src/views/docs/WasmSupport.vue): `GetCollection<Todo>()` non verificato nel core.
- [Encryption.vue](src/views/docs/Encryption.vue): `BLiteEngineOptions` non verificato nel core.
- [AuditTrail.vue](src/views/docs/AuditTrail.vue): varie classi non verificate nel core.
- [GDPR.vue](src/views/docs/GDPR.vue): `HasSecureErase()` e `BLiteEngineOptions` non verificati nel core.

## Conclusione operativa

La strategia corretta non e` rendere tutto duale. Le pagine davvero bivalenti sono quelle dove il caso d’uso esiste sia in modalita` typed sia in modalita` schema-less. Le pagine specialistiche devono invece restare focalizzate:

- `Querying` resta typed-only.
- `BLQL` resta dynamic-only.
- `DynamicAPI` resta dynamic-only.
- `TimeSeries`, `KvStore`, `Converters`, `Transactions`, `GettingStarted` sono i candidati migliori per esempi paralleli, ma solo dopo avere riallineato i nomi delle API ai sorgenti reali.

In breve: prima si correggono i nomi che non esistono piu`, poi si decide dove mostrare la bivalenza vera, non artificiale.