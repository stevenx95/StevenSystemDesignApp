-- Seed content — run AFTER schema.sql
-- Fixed UUIDs so topics/problems/flashcards can reference each other predictably.
-- Feel free to edit/add more rows later directly in the Supabase Table Editor.

-- ============ EASY TOPICS (sequenced as a story) ============

insert into topics (id, name, difficulty, sequence_order, summary, source_links, blog_links) values
('10000000-0000-0000-0000-000000000001', 'Single server setup', 'easy', 1,
 'Every system starts here: one server running the app, the database, and everything else together. It is the simplest thing that can work, and understanding its limits (one point of failure, one machine''s worth of CPU/RAM/disk) is what motivates every topic that follows.',
 '[{"title":"System Design Primer","url":"https://github.com/donnemartin/system-design-primer"}]',
 '[]'),

('10000000-0000-0000-0000-000000000002', 'Separating the database', 'easy', 2,
 'The first split: move the database onto its own machine. Now the app server and the database can be scaled, restarted, and monitored independently, and a crash in one doesn''t necessarily take down the other.',
 '[{"title":"karanpratapsingh - System Design Basics","url":"https://karanpratapsingh.com/courses/system-design/basics"}]',
 '[]'),

('10000000-0000-0000-0000-000000000003', 'Vertical vs horizontal scaling', 'easy', 3,
 'Vertical scaling means adding more power (CPU/RAM) to one existing machine — simple, but there''s a hard ceiling and a single point of failure. Horizontal scaling means adding more machines and splitting the load across them — more complex to coordinate, but it scales further and survives individual machine failures.',
 '[{"title":"System Design Primer - Scalability","url":"https://github.com/donnemartin/system-design-primer#scalability"}]',
 '[]'),

('10000000-0000-0000-0000-000000000004', 'Load balancers', 'easy', 4,
 'Once you have multiple app servers (horizontal scaling), something needs to decide which server handles each incoming request — that''s the load balancer. It also enables active-active or active-passive failover: if one server goes down, traffic just routes to the others.',
 '[{"title":"System Design Primer - Load balancer","url":"https://github.com/donnemartin/system-design-primer#load-balancer"}]',
 '[{"company":"Cloudflare","title":"What is a load balancer?","url":"https://www.cloudflare.com/learning/performance/what-is-load-balancing/"}]'),

('10000000-0000-0000-0000-000000000005', 'Caching', 'easy', 5,
 'A cache stores the result of expensive work (a DB query, a computation) so the next request for the same thing is nearly instant. The tradeoff is staleness: cached data can go out of date, so every caching strategy is really a decision about how fresh the data needs to be.',
 '[{"title":"System Design Primer - Caching","url":"https://github.com/donnemartin/system-design-primer#cache"}]',
 '[{"company":"Netflix","title":"Netflix Tech Blog","url":"https://netflixtechblog.com/"}]'),

('10000000-0000-0000-0000-000000000006', 'Content delivery networks (CDN)', 'easy', 6,
 'A CDN is a network of servers spread across the world that cache and serve static content (images, video, JS/CSS) from a location physically close to the user, cutting down load time. It''s essentially "caching," but for geography instead of for a single server.',
 '[{"title":"System Design Primer - CDN","url":"https://github.com/donnemartin/system-design-primer#content-delivery-network"}]',
 '[{"company":"Cloudflare","title":"Cloudflare blog","url":"https://blog.cloudflare.com/"}]'),

('10000000-0000-0000-0000-000000000007', 'DNS basics', 'easy', 7,
 'DNS translates a human-readable domain name into the IP address a computer actually needs to connect to. It''s the very first hop of nearly every request on the internet, so knowing how it resolves (and how it can route traffic to different servers) matters for almost every system design problem.',
 '[{"title":"System Design Primer - DNS","url":"https://github.com/donnemartin/system-design-primer#domain-name-system"}]',
 '[]'),

('10000000-0000-0000-0000-000000000008', 'Database replication', 'easy', 8,
 'Replication keeps copies of your database on multiple machines. The common pattern is one primary (handles writes) and one or more replicas (handle reads), which spreads out read traffic and gives you a backup if the primary fails — at the cost of replicas sometimes lagging slightly behind.',
 '[{"title":"System Design Primer - Replication","url":"https://github.com/donnemartin/system-design-primer#database"}]',
 '[]');

-- ============ MEDIUM TOPICS ============

insert into topics (id, name, difficulty, sequence_order, summary, source_links, blog_links) values
('20000000-0000-0000-0000-000000000001', 'SQL vs NoSQL', 'medium', 9,
 'SQL databases enforce a fixed schema and strong relational guarantees (ACID) — good when your data has clear structure and relationships. NoSQL databases (key-value, document, wide-column, graph) trade some of that structure/consistency for flexibility and easier horizontal scaling — good for very large, loosely-structured, or fast-changing data.',
 '[{"title":"karanpratapsingh - Databases","url":"https://karanpratapsingh.com/courses/system-design/databases"}]',
 '[]'),

('20000000-0000-0000-0000-000000000002', 'Database sharding', 'medium', 10,
 'Sharding splits one large database into smaller pieces (shards), each holding a subset of the data, spread across multiple machines. It solves the problem replication alone can''t: when the data itself is too big for one machine, not just the read traffic.',
 '[{"title":"System Design Primer - Sharding","url":"https://github.com/donnemartin/system-design-primer#sharding"}]',
 '[{"company":"Uber","title":"Uber Engineering blog","url":"https://www.uber.com/blog/engineering/"}]'),

('20000000-0000-0000-0000-000000000003', 'CAP theorem & consistency patterns', 'medium', 11,
 'The CAP theorem says a distributed system can''t guarantee Consistency, Availability, and Partition tolerance all at once during a network partition — you have to pick which two matter more for your case. This is the theoretical backbone behind why systems choose "eventual consistency" (fast, always available, briefly stale) vs "strong consistency" (always correct, sometimes slower or unavailable).',
 '[{"title":"System Design Primer - CAP theorem","url":"https://github.com/donnemartin/system-design-primer#cap-theorem"}]',
 '[]'),

('20000000-0000-0000-0000-000000000004', 'Message queues & async processing', 'medium', 12,
 'Instead of making a user wait for slow work to finish, you drop a message on a queue and return a response immediately; a separate worker processes the queue in the background. This decouples the producer and consumer of work and smooths out spikes in traffic.',
 '[{"title":"System Design Primer - Asynchronism","url":"https://github.com/donnemartin/system-design-primer#asynchronism"}]',
 '[{"company":"Airbnb","title":"Airbnb Engineering blog","url":"https://medium.com/airbnb-engineering"}]'),

('20000000-0000-0000-0000-000000000005', 'Microservices & service discovery', 'medium', 13,
 'Instead of one large application, the system is split into small, independently-deployable services, each owning one responsibility. This adds flexibility and fault isolation, but introduces a new problem — services need a way to find and call each other, which is what service discovery solves.',
 '[{"title":"System Design Primer - Microservices","url":"https://github.com/donnemartin/system-design-primer#microservices"}]',
 '[{"company":"Netflix","title":"Netflix Tech Blog","url":"https://netflixtechblog.com/"}]'),

('20000000-0000-0000-0000-000000000006', 'REST vs RPC', 'medium', 14,
 'REST models communication around resources (nouns) and standard HTTP verbs — widely understood, cacheable, and a natural fit for public APIs. RPC models it around actions (verbs, like calling a function remotely) — often faster and more efficient for internal service-to-service communication where both sides control the contract.',
 '[{"title":"System Design Primer - Communication","url":"https://github.com/donnemartin/system-design-primer#communication"}]',
 '[]');

-- ============ HARD TOPICS ============

insert into topics (id, name, difficulty, sequence_order, summary, source_links, blog_links) values
('30000000-0000-0000-0000-000000000001', 'Consistent hashing', 'hard', 15,
 'A technique for distributing data across shards/servers so that when you add or remove a server, only a small fraction of data needs to move — instead of nearly everything, as with naive modulo-based hashing. This is what makes sharded/distributed systems practical to scale up or down over time.',
 '[{"title":"System Design Primer - Consistent hashing","url":"https://github.com/donnemartin/system-design-primer"}]',
 '[]'),

('30000000-0000-0000-0000-000000000002', 'Leader election & consensus', 'hard', 16,
 'In a distributed system with multiple nodes, you often need them to agree on one fact (who''s the leader, what the latest value is) even if some nodes fail or messages get delayed. Algorithms like Paxos and Raft solve this class of problem, and are the hidden foundation under most "highly available" distributed databases.',
 '[{"title":"High Scalability blog","url":"https://highscalability.com/"}]',
 '[]'),

('30000000-0000-0000-0000-000000000003', 'Multi-region / geo-distributed design', 'hard', 17,
 'Serving users across the globe with low latency means running the system in multiple data center regions at once — which raises hard questions about where writes go, how data replicates between regions, and what happens if a whole region goes down.',
 '[{"title":"High Scalability blog","url":"https://highscalability.com/"}]',
 '[{"company":"Meta","title":"Meta Engineering blog","url":"https://engineering.fb.com/"}]'),

('30000000-0000-0000-0000-000000000004', 'Rate limiting at scale', 'hard', 18,
 'Protecting a system from being overwhelmed (by abuse or just legitimate spikes) by capping how many requests a client can make in a time window. At scale this itself becomes a distributed systems problem — the counters need to be tracked consistently across many servers.',
 '[{"title":"System Design Primer - Rate limiting pattern","url":"https://github.com/donnemartin/system-design-primer"}]',
 '[{"company":"Cloudflare","title":"Cloudflare blog","url":"https://blog.cloudflare.com/"}]');

-- ============ PROBLEMS ============

insert into problems (id, title, difficulty, related_topic_ids, hints, solution) values
('40000000-0000-0000-0000-000000000001', 'Design a URL shortener', 'easy',
 array['10000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000008']::uuid[],
 '["What are you actually storing — just the long URL, or also click counts, creation date, expiry?", "How would you turn a long URL into a short, unique code? Think about encoding a number vs. hashing.", "What happens on a redirect request — where does the read come from, and could caching help here?"]',
 'Requirements: shorten a long URL into a short code, redirect short -> long, handle far more reads (redirects) than writes (new links).

High-level design: a write API takes a long URL, generates a unique short code (commonly base62-encoding an auto-incrementing ID, or hashing the URL and taking the first few characters with collision checks), and stores {short_code, long_url, created_at} in a database. A read API takes a short code, looks up the long URL, and issues an HTTP redirect.

Scaling it: since reads (redirects) vastly outnumber writes, put a cache (like the "Caching" topic) in front of the database for short_code -> long_url lookups. A single database can typically handle this at moderate scale; if it grows very large, shard by short_code. Use a CDN/edge cache for extremely popular links. Keep the ID generation simple and centralized at first (single counter or a small reserved-range-per-server scheme) rather than reaching for distributed ID generation before you actually need it.'),

('40000000-0000-0000-0000-000000000002', 'Design a Twitter-style timeline', 'medium',
 array['20000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000005']::uuid[],
 '["When a user posts, should the timeline update immediately for all their followers, or only when a follower opens their feed?", "What''s different about a user with 10 followers vs. a celebrity with 50 million?", "Where would a queue fit into the write path?"]',
 'Requirements: users follow other users; each user sees a reverse-chronological feed of posts from people they follow; reads (viewing a feed) vastly outnumber writes (posting).

Two core strategies: "fan-out on write" (when a user posts, immediately push the post into every follower''s pre-computed timeline, stored in a cache) makes reads instant but is expensive for users with huge follower counts. "Fan-out on read" (build the timeline by querying all followed users'' posts at read time) is cheap to write but slower to read.

Practical design: use fan-out on write for most users (push new posts into followers'' cached timelines via a background worker off a message queue, so the post API returns fast), but fall back to fan-out on read for celebrity accounts with huge follower counts (merge their posts into a viewer''s timeline at read time instead of writing to millions of cached timelines). Shard the post storage by user ID, and cache each user''s timeline (a list of post IDs) rather than recomputing it from scratch every time.'),

('40000000-0000-0000-0000-000000000003', 'Design a web crawler', 'hard',
 array['20000000-0000-0000-0000-000000000004','30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000002']::uuid[],
 '["How do you avoid crawling the same URL twice, across many crawler machines running in parallel?", "How do you avoid hammering one domain with too many simultaneous requests?", "What data structure tracks ''URLs to visit'' at a scale of billions?"]',
 'Requirements: given a set of seed URLs, discover and download web pages at massive scale, extract new links from each page, and repeat, while being polite to individual servers and avoiding duplicate work.

High-level design: a URL frontier (a distributed queue, partitioned so the same domain always lands on the same partition, which enables per-domain rate limiting) feeds URLs to a pool of worker machines. Each worker fetches a page, extracts links, and pushes new URLs back into the frontier. A distributed "seen" set (often a hash set backed by a sharded key-value store, or a probabilistic structure like a Bloom filter to save memory at huge scale) prevents re-crawling the same URL. Consistent hashing assigns domains/URLs to specific frontier partitions and worker shards so that adding or removing crawler machines doesn''t reshuffle everything. Store the downloaded content and metadata in a sharded, replicated storage layer, decoupled from the crawling workers themselves.');

-- ============ FLASHCARDS ============

insert into flashcards (type, front, back, difficulty, related_topic_id) values
('definition', 'What is horizontal scaling?', 'Adding more machines to share the load, instead of making one machine bigger. Requires a way to distribute work across machines (e.g. a load balancer) but avoids a hard ceiling and a single point of failure.', 'easy', '10000000-0000-0000-0000-000000000003'),
('definition', 'What does a load balancer do?', 'Sits in front of multiple servers and distributes incoming requests across them, enabling horizontal scaling and failover if one server goes down.', 'easy', '10000000-0000-0000-0000-000000000004'),
('definition', 'What is a CDN?', 'A network of geographically distributed servers that cache static content close to users, reducing latency versus serving everything from one origin server.', 'easy', '10000000-0000-0000-0000-000000000006'),
('definition', 'What does database replication give you?', 'Copies of your data on multiple machines (typically one primary for writes, replicas for reads), which spreads out read load and provides a failover option if the primary goes down.', 'easy', '10000000-0000-0000-0000-000000000008'),
('tradeoff', 'SQL vs NoSQL — when would you pick which?', 'Pick SQL when your data is structured, relationships matter, and you need strong consistency (e.g. financial records). Pick NoSQL when you need to scale horizontally with flexible/changing data shapes and can tolerate weaker consistency (e.g. activity feeds, session data).', 'medium', '20000000-0000-0000-0000-000000000001'),
('tradeoff', 'Strong consistency vs eventual consistency — when would you pick which?', 'Pick strong consistency when every reader must see the latest write immediately (e.g. an account balance). Pick eventual consistency when brief staleness is acceptable in exchange for better availability and lower latency (e.g. a social media like-count).', 'medium', '20000000-0000-0000-0000-000000000003'),
('tradeoff', 'Fan-out on write vs fan-out on read — when would you pick which?', 'Fan-out on write (push data to followers immediately) is great for fast reads but expensive when someone has millions of followers. Fan-out on read (compute at request time) is cheap to write but slower per read. Many real systems use write-fanout for normal users and read-fanout for very high-follower accounts.', 'medium', '20000000-0000-0000-0000-000000000004'),
('tradeoff', 'REST vs RPC — when would you pick which?', 'Pick REST for public-facing APIs where wide compatibility, caching, and resource-based design matter. Pick RPC for internal service-to-service calls where both sides are controlled by you and raw performance/efficiency matters more than broad compatibility.', 'medium', '20000000-0000-0000-0000-000000000006');

-- ============ ESTIMATION DRILLS ============

insert into estimation_drills (scenario, answer_guidance, difficulty) values
('A URL shortener has 100 million new short links created per month, and each link is clicked (read) 100 times on average over its lifetime. Estimate the writes/second and reads/second the system needs to handle on average.',
 'Writes: 100,000,000 / (30 days x 86,400 sec) ≈ 38.5 writes/sec on average. Reads: 100x that ≈ 3,850 reads/sec on average. The key lesson: reads dominate by orders of magnitude, which is exactly why caching redirects matters more than optimizing the write path.',
 'easy'),
('A social app has 50 million daily active users, each posting an average of 2 times per day. Estimate posts/second at average load, and discuss why peak load might be far higher.',
 'Average: 50,000,000 x 2 / 86,400 ≈ 1,157 posts/sec. Peak load is often 5-10x average because usage isn''t evenly spread across the day (e.g. everyone posts during a major live event) — systems should be designed and load-tested for peak, not average.',
 'medium');
