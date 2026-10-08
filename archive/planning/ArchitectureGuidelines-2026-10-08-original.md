## Complete System Architecture Guidelines

================================================================================
SYSTEM ARCHITECTURE: SECURE SERVERLESS W-9 INTAKE & ADMINISTRATIVE DASHBOARD
================================================================================

1. SYSTEM INFRASTRUCTURE & CONSTRAINTS
   - Platform Deployment: Deployed completely on Cloudflare Pages.
   - Frontend Engine: Astro Framework.
   - Backend Execution: Cloudflare Pages Functions running on the 'workerd' 
     V8-isolate edge runtime. 
   - Core Constraint: Prefer NO Node.js core module dependencies (e.g., 
     'fs', 'path', 'crypto' from the Node ecosystem are forbidden). All logic 
     must use environment-agnostic, browser-compatible Web Standards APIs. RUST may be best.
   - Financial Boundary: Architected to operate within the limits 
     of Cloudflare's Free Tier for D1, R2, Pages, and Workers for now. We have a $5/month account with CloudFlare and if this gains traction we can move to a more robust architecture on fly.dev or remain on cloudflare.

2. STORAGE & PERSISTENCE STRATEGY
   - Database Layer: Cloudflare D1 (managed serverless SQLite engine). Holds 
     structured vendor profiles, session hashes, metadata, and encrypted tax strings.
   - Object Storage Layer: Cloudflare R2 (S3-compatible blob storage). Holds 
     the final, flattened, immutable PDF files. 
   - Decoupling Rule: Binary document bytes or base64 data strings must never 
     be stored directly in the SQLite rows. Instead, rows must utilize 
     cryptographic UUIDv4 string paths acting as pointers to the R2 bucket objects.

3. SECURITY & CRYPTOGRAPHIC ENGINE
   - Sensitive Data Vaulting: Taxpayer Identification Numbers (SSNs or EINs) 
     cannot be saved in plain text. Field-level encryption must occur inside 
     the Worker isolate before network transmission to the data tier.
   - Cryptographic Target: Natively utilize the global Web Crypto API 
     (crypto.subtle). Implement 256-bit AES-GCM authenticated encryption using 
     keys derived from secure environment variables.
   - Storage Hygiene: Every single encrypted record must distinctly save its 
     unique initialization vector (IV) alongside the ciphertext to prevent 
     cryptographic degradation.
   - Legal Compliance: The system must enforce the ESIGN Act framework by 
     capturing an unalterable audit log (combining the confirmed vendor email, 
     the 'CF-Connecting-IP' header, and a millisecond-precision UTC timestamp) 
     and burning a receipts block directly into the PDF footer.

4. USER INTERFACES & AUTHENTICATION FLOW
   - Public Vendor Intake: An intuitive Astro portal containing a responsive 
     HTML5 canvas element driven by a zero-dependency package ('signature_pad'). 
     Strokes are converted to a transparent PNG string in-browser and pushed via 
     a secured JSON TLS request to the backend.
   - Document Compilation: The edge backend parses the payload, reads a static 
     official IRS Form W-9 PDF template byte stream using 'pdf-lib' (edge build), 
     maps form data via geometric Cartesian point coordinates, stamps the PNG 
     signature, and permanently flattens vector layers to prevent alterations.
   - Administrative Dashboard: A restricted UI tracking total submissions, a 
     tabular overview of individual vendors, and deep-link file viewers.
   - Session Controls: Bypasses heavy Node libraries. Authenticates admins via 
     Web Crypto hashing, issuing an 'HttpOnly', 'Secure', 'SameSite=Strict' cookie 
     holding an edge-verified secure signature. Access boundaries are protected via 
     an Astro Edge Middleware script intercepting all routes within '/dashboard/*'.

5. BULK PACKAGING & ARCHIVING LAYER
   - Chunked Processing: Bulk exports must not exceed the localized worker 
     memory heap boundaries. Memory-heavy Node compression tools are strictly banned.
   - Execution Loop: The backend must process bulk requests by pulling listed 
     pointers from D1, streaming binary documents concurrently from Cloudflare R2 
     via standard streams, and passing chunks into the lightweight, edge-native 
     'fflate' zipping utility to write files dynamically to a single compressed archive.
   - Client Delivery: Stream the dynamically generated binary zip bundle directly 
     back to the admin browser using an 'application/zip' MIME container wrapper.


