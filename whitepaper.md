---
title: librotenado
subtitle: An open protocol for accounting data in Europe
version: 0.1
status: Draft
---

> [!NOTE]
> First full draft (v0.1). All chapters are written; statements marked **OPEN** are not yet verified and are
> collected under "Open points" at the end. Sources are numbered in square brackets and listed under "Sources".

## 1. Summary

**librotenado is an open protocol for accounting data in Europe.** It defines one harmonised model for everything a
set of books consists of – organisations, periods, a chart of accounts, bookings, currencies, receipts, invoices,
reports and filings – and treats the formats that already exist as translations of that model: European e-invoices
(EN 16931 and Peppol), national e-invoicing and reporting systems, SAF-T audit files, ISO 20022 bank statements, XBRL
financial statements and national charts of accounts.

Four ideas carry the protocol:

- **One model, many translations.** The model is the reference. Every existing format is a translation into and out
  of it – unambiguous, reversible where the format allows, versioned and tested per country. Where a country
  distinguishes more finely than the model, the model grows; a translation never bends.
- **The original stays the receipt.** An incoming e-invoice, a bank statement or a scanned receipt is kept exactly as
  received. Translations make it usable; they never replace it.
- **Synchronisation is built in.** Books are a growing set of immutable events, ordered by hybrid logical clocks and
  chained by hashes. Where two devices produce something the rules forbid, the protocol puts it on a review list
  instead of merging it silently.
- **Open for everyone.** The specification is published under CC BY 4.0, the reference library under the MIT licence.
  Anyone may implement librotenado – free projects and commercial vendors alike.

librotenado is published by falkOSS, a non-profit company for free software in formation in Germany. Its first
implementation is the free accounting software spezado; the protocol itself belongs to no product and is designed so
that it can later move to an independent body or a standards organisation.

## 2. The problem

### 2.1 One business, many formats

Accounting data in Europe is increasingly exchanged in structured, machine-readable form – but country by country.

- **Invoices.** The European standard EN 16931 defines the semantic data model of an electronic invoice, with two
  syntaxes (UBL and UN/CEFACT CII); Directive 2014/55/EU requires public contracting authorities to accept invoices
  that comply with it [1][2]. Peppol BIS Billing 3.0 is a Core Invoice Usage Specification (CIUS) of EN 16931 and is
  used on the Peppol network [3].
- **National e-invoicing systems.** On top of the common standard, member states have built their own systems:
  Italy has required electronic invoices between resident businesses through its exchange system SdI since
  1 January 2019 [4]; Poland's national system KSeF became mandatory in stages from 1 February 2026 [5]; Spain
  regulates invoicing software itself and requires chained invoice records under the VERI\*FACTU regulation [6][7]
  (current application dates **OPEN**); France requires all businesses to be able to receive electronic invoices
  from 1 September 2026, with issuing obligations phased in until 2027 [8]; Germany has required businesses to be
  able to receive e-invoices since 1 January 2025, with transitional rules for issuing [9].
- **Cross-border reporting.** With the VAT in the Digital Age package, the EU introduces digital reporting
  requirements based on e-invoicing; for cross-border B2B transactions they apply from 1 July 2030 [10][11].
- **Audit files.** The OECD's Standard Audit File for Tax (SAF-T) describes an XML file that a tax authority can
  request from a business's accounting system [12]. Countries adopt their own variants – Norway, for example,
  requires the SAF-T Financial format for accounting periods from 2020 [13].
- **Bank statements.** ISO 20022 defines the cash management messages (camt) in which banks report booked entries
  and balances to account holders, among them camt.053 BankToCustomerStatement [14].
- **Financial statements.** Listed issuers in the EU publish annual financial reports in the European Single
  Electronic Format with Inline XBRL [15]; Germany requires balance sheet and profit and loss account to be
  transmitted electronically to the tax authority (§ 5b EStG) [16], in XBRL according to an official taxonomy [17].
- **Charts of accounts.** Some countries prescribe a national chart of accounts. France's Plan comptable général
  applies to every entity required to prepare annual accounts and contains a detailed nomenclature of accounts [18];
  how strictly the account numbers bind is **OPEN**. Belgium has a minimum standardised chart of accounts (PCMN),
  consolidated in a royal decree of 21 October 2018 – its exact scope is **OPEN**. Other countries leave the chart to
  the business; in Germany, for example, standard charts from software vendors are common practice (**OPEN**:
  source).

### 2.2 Standards for the parts, no model for the whole

Each of these standards is good at its part. EN 16931 describes an invoice, camt.053 a bank statement, SAF-T an
audit extract, XBRL a financial statement. None of them describes the books as a whole: how an invoice becomes a
booking, how a bank entry settles it, how bookings add up to a statement, how that statement becomes a filing – and
how all of this is kept consistent while several people and devices work on it.

Accounting software fills that gap with its own internal model. Every vendor builds one, every vendor translates the
same national formats into it, and every vendor carries the cost of following each country's changes.

### 2.3 What gets lost

When books move – from one program to another, from one vendor to the next, from a business to its tax adviser, or
across a border – they usually move through an export format that was built for a different purpose: a SAF-T file
for the auditor, a CSV export, a vendor-specific interchange format. What the target format cannot express is lost:
the link between a booking and its receipt, the history of corrections, the finer distinctions of the source chart
of accounts. librotenado does not quantify that loss; no reliable figures are known to the authors (**OPEN**).

## 3. Principles

1. **One model as the reference.** There is exactly one librotenado model. Formats, countries and products are
   described in relation to it, never the other way round.
2. **Translations are exact.** A translation is unambiguous: one input yields one output. Where a format can carry
   everything the model holds for a given document, the translation is reversible; where it cannot, the
   specification states what is dropped, and nothing is invented on the way back.
3. **The model grows, translations do not bend.** If a country distinguishes something the model does not, the model
   is extended – for everyone – instead of hiding the distinction in a country-specific mapping.
4. **The original is the receipt.** A received document is stored byte for byte. Derived data refers to it; it never
   replaces it.
5. **Nothing is overwritten.** Books are append-only. Corrections are new events that refer to what they correct.
6. **Conflicts are visible.** When concurrent work breaks a rule of accounting, a person decides. The protocol never
   resolves such a conflict silently.
7. **Private by design.** Books are end-to-end encrypted between the people and devices that share them. Whoever
   transports them does not need to read them.
8. **Open for everyone.** The specification is free to read, implement and extend; the reference library is free to
   use in any product.

## 4. The model

The model is described here in outline; the normative definitions belong in the specification.

### 4.1 Organisations and periods

An **organisation** is the entity whose books are kept: a company, an association, a sole trader, a household. It
carries its legal identifiers (for example VAT and tax numbers, register entries) as typed attributes, each with the
country and scheme that issued it. An organisation has **fiscal periods**; a period can be open, provisionally closed
or closed. Once a period is closed, no event may change its bookings – corrections go into an open period.

### 4.2 A harmonised chart of accounts

The chart of accounts is the core of the model. Instead of a flat list of numbers, it is a **hierarchy of accounts
with attributes**: what kind of item an account holds (asset, liability, equity, income, expense), its tax treatment,
its counterparty type, its role in statements, and further attributes as countries require them.

The aim is a chart that is **at least as fine as every national chart** it translates to. A national chart then
becomes a view on the harmonised one: each national account corresponds to a set of harmonised accounts selected by
their attributes. Because the harmonised chart is the finer one, the mapping from harmonised to national is always
defined; the mapping from national to harmonised needs, at most, the attributes a business adds when it opens an
account. Where a national chart draws a line that no harmonised attribute can express, a new attribute or account is
added to the model.

Organisations may add their own sub-accounts below the harmonised ones; they inherit all attributes of their parent,
so every translation still works.

### 4.3 Bookings as immutable events

A **booking** is a balanced set of debit and credit lines on accounts, with a date, a period, a text and references
to the receipts it is based on. Bookings are recorded as **events**: once written, an event never changes. A
correction is a reversal event plus a new booking, both referring to the original. The current state of the books –
balances, open items, statements – is derived from the events.

### 4.4 Currencies

Every amount carries its currency. A booking in a foreign currency keeps the original amount and the amount in the
organisation's functional currency, together with the exchange rate and its source. Revaluations at period end are
bookings like any other. Currency codes follow ISO 4217 [25].

### 4.5 Receipts

A **receipt** is any document that supports a booking: an incoming e-invoice, a PDF, a photo of a till slip, a bank
statement, a contract. The model stores the original bytes, a cryptographic hash, the media type and, where the
document is structured, a reference to its parsed form. A receipt is never edited; a better scan is a new receipt.

### 4.6 Invoices

An **invoice** in the model covers everything EN 16931 can express, plus what national systems add (for example
clearance identifiers returned by a tax authority). Outgoing invoices are generated from the model and then
translated into the format the recipient or the country requires; incoming invoices are stored as receipts and
translated into the model.

Invoice numbers must be unique. The EU VAT Directive requires a sequential number "based on one or more series"
that uniquely identifies the invoice [19]. librotenado uses this: every device that issues invoices receives its own
**number range** (a series), so that devices working offline never issue the same number.

### 4.7 Reports and filings

**Reports** – trial balance, balance sheet, profit and loss account, VAT summaries – are defined as functions of the
events and the chart of accounts. Because every report is derived, it can be recomputed for any point in time and
any version of the rules.

A **filing** is a report submitted to an authority. The model records what was submitted, in which format, when, the
authority's acknowledgement and any correction filed later. The submitted document and the acknowledgement are kept
as receipts.

## 5. Translations

### 5.1 What a translation is

A translation is a versioned pair of functions between the model and one external format: an **import** (format to
model) and an **export** (model to format). Each translation states:

- the exact format version it implements (for example a specific Peppol BIS or SAF-T release);
- for every element of the format, the model element it maps to;
- what, if anything, is lost in either direction;
- the test cases that prove the above.

A translation is **unambiguous**: the same input always yields the same output. It is **reversible** where the format
permits: importing an exported document gives back the original model data, and exporting an imported document gives
back an equivalent document. Where reversibility is impossible – because a format has fewer fields than the model –
the specification names the difference instead of guessing.

### 5.2 Formats in scope

| Family | Examples | Role in the model |
|---|---|---|
| European e-invoice | EN 16931 (UBL, CII), Peppol BIS Billing 3.0 [1][3] | invoices in and out |
| National e-invoicing and reporting | SdI (Italy) [4], KSeF (Poland) [5], VERI\*FACTU (Spain) [6], French reform [8], German formats [9] | invoices, clearance and reporting data |
| Audit files | SAF-T and national variants [12][13] | export of the books for authorities and auditors |
| Bank statements | ISO 20022 camt.053 [14] | import of bank entries as receipts, matching to open items |
| Financial statements | XBRL, Inline XBRL / ESEF [15], E-Bilanz [17] | export of reports |
| Charts of accounts | national charts, e.g. France [18] | views on the harmonised chart |

The list per country – which formats are mandatory, from when, for whom – is maintained in the specification, with
a source for every entry (**OPEN**: first complete country list).

### 5.3 Versioned and tested per country

Formats change: schemas get new versions, taxonomies are updated, national rules move dates. librotenado therefore
versions each translation independently of the model. A document always records which translation version produced
it, so it can be read again years later with the same rules.

Every translation comes with a **public test suite**: example documents for each country, the expected model data,
and round-trip tests. Official example files and validation artefacts published by authorities and standards bodies
are used wherever their licences allow (**OPEN**: licence review per source). An implementation that passes the
suite for a country can say so.

### 5.4 Originals stay

When an e-invoice arrives – say as an XML document in a national format – librotenado stores that document unchanged
as the receipt and imports a translation into the model. A rendering for people, a translation into another format or
an export for an auditor is always derived from the original and never replaces it. This keeps the books aligned
with retention rules that refer to the document as received; for Germany, the exact requirements for retaining the
structured part of an e-invoice are **OPEN** (source: the tax administration's guidance on e-invoicing [9]).

## 6. Synchronisation and security

### 6.1 A growing set of events

The books of an organisation are a set of immutable events that only grows. Devices – a phone, a laptop, a server,
a tax adviser's software – exchange the events they are missing. Because events never change and are identified by
their hash, exchanging them is idempotent: receiving the same event twice changes nothing, and the order of arrival
does not matter for which events exist.

### 6.2 Ordering with hybrid logical clocks

To present events in a meaningful order and to tell which events a device knew when it wrote a new one, each event
carries a **hybrid logical clock** timestamp. Hybrid logical clocks combine physical time with a logical counter: they
capture causality like logical clocks while staying close to wall-clock time [20]. The accounting date of a booking is
separate from this timestamp – a booking dated last month can be recorded today.

### 6.3 A hash chain per device

Each device chains its own events: every event contains the hash of the device's previous event. A gap or an altered
event in a device's history is therefore detectable by anyone who holds the chain. The idea is established in tax
practice: Spain's VERI\*FACTU regulation requires each invoice record to contain the hash of the previous record [7].
librotenado applies it to all events, per device, so that devices can work offline without coordinating.

A hash is only useful if every implementation computes the same one. Events are therefore hashed over a canonical
encoding – JSON as defined by the JSON Canonicalization Scheme [26], without floating-point numbers – that any
implementation can reproduce byte for byte.

### 6.4 Invariants and the review list

Accounting has rules that concurrent work can break. Examples:

- **unique invoice numbers** – prevented by number ranges per device (4.6), and detected if ranges were misconfigured;
- **closed periods** – a device that was offline records a booking in a period that another device has since closed;
- **double reversals** – two devices reverse the same booking independently;
- **unbalanced states** – for example an open item settled twice by two bank matches.

The specification lists these **invariants**. After every synchronisation, an implementation checks them. A
violation is never resolved automatically: the affected events go onto a **review list**, where a person decides –
for example by keeping one reversal and reversing the other. The decision is itself an event, so the resolution is
part of the books and visible to auditors.

### 6.5 End-to-end encryption for groups

Books are shared by groups that change over time: the owners, an accountant, a tax adviser, several devices per
person. librotenado encrypts events end to end for such a group. The candidate protocol is **Messaging Layer
Security (MLS)**, RFC 9420, which lets groups from two to thousands of members agree on shared keys asynchronously,
with forward secrecy and post-compromise security [21]. Whether MLS fits all requirements – for example long-term
access to old periods after members leave, and key recovery for an organisation – is **OPEN**.

### 6.6 Relays and backends

Two kinds of servers can take part:

- A **relay** stores and forwards encrypted events. It sees which group an event belongs to and its size, but not its
  content. Because a relay needs no trust beyond availability, anyone can run one – a vendor, an association, a
  hosting company, and later possibly public bodies (**OPEN**: interest and legal framework).
- A **backend** is a full participant: it holds keys, reads the books and can, for example, compute reports or submit
  filings on behalf of the organisation. A backend is a trusted peer of the group, added and removed like a device.

An organisation can therefore choose between keeping everything on its own devices, using a relay for availability,
or using a backend for services – and change its choice without changing its books.

## 7. Filings

Most filings follow the same pattern: compute a report from the books, translate it into the format an authority
prescribes, submit it through the authority's channel, and record the acknowledgement. librotenado defines **one open
interface** for this pattern – inputs, the submitted document, status, acknowledgement, corrections – and **adapters
per country** that implement it.

The first adapter targets Germany, where tax filings are submitted through ELSTER; the tax administration provides
software vendors with the ERiC library for checking and transmitting data [22]. Under which conditions an open
implementation may integrate ERiC is **OPEN**. Further adapters follow the country list of chapter 5.

Each adapter records what it submitted as a receipt, so that a filing can always be traced back to the bookings it
was computed from.

## 8. Implementations

librotenado is meant to have many implementations. The project provides:

- **the specification** – the model, the translations, the synchronisation and encryption rules, the filing
  interface, and the test suites;
- **a reference library in Rust** – data model, translations, synchronisation and encryption, usable from other
  languages through bindings (**OPEN**: which bindings first).

The first application built on librotenado is **spezado**, a free accounting program. It is one implementation among
the ones that may follow; the specification makes no assumption about it.

## 9. Licences and governance

### 9.1 Licences

- **Specification and whitepaper: CC BY 4.0** [23] – anyone may copy, adapt and build on the text, including in
  standards documents and commercial products, with attribution.
- **Reference library: MIT** [24] – anyone may use it in free or proprietary software.
- Formats, schemas and taxonomies of third parties keep their own licences; the specification refers to them and
  reuses them only as far as their licences allow.

Contributions are accepted under the Developer Certificate of Origin, without a contributor licence agreement.

### 9.2 Versioning

The model, each translation and the synchronisation protocol carry their own version numbers. Additions that do not
change the meaning of existing data are minor versions; anything else is a major version with a documented migration.
Because events record the versions that produced them, old books stay readable.

### 9.3 Governance

librotenado is published by falkOSS, a non-profit company for free software in formation in Germany (**OPEN**: status
of the incorporation and of the non-profit recognition at publication). The protocol is kept separate from any
product from the start – its own organisation, repositories, website and whitepaper – so that it can move as a whole
to an independent body, a foundation or a standards organisation when the community of implementers is ready for it.
Which body and which process is **OPEN**.

Until then, decisions are taken in public: proposals as issues, changes as pull requests, every claim about an
existing standard with a source.

## 10. Next steps

1. Publish version 0.1 of the specification and the reference library together with the first version of spezado.
2. Complete the country list with sources (chapter 5).
3. Write the first translations with test suites: EN 16931 / Peppol BIS, a German national e-invoice format, ISO 20022
   camt.053, SAF-T.
4. Specify the harmonised chart of accounts against at least two national charts.
5. Evaluate MLS against the requirements in 6.5.
6. Build the filing interface and the first adapter (Germany).
7. Invite implementers, tax advisers and public bodies to review the model.

## Open points

- **Germany, charts of accounts:** source for the practice of vendor standard charts (2.1).
- **France, PCG:** how strictly the account numbers of the Plan comptable général bind (2.1).
- **Belgium, PCMN:** scope of the minimum standardised chart of accounts and the decree of 21 October 2018 (2.1).
- **Spain, VERI\*FACTU:** current application dates; they have been changed since the regulation was adopted (2.1).
- **Information loss:** no reliable figures on what is lost when books move between programs (2.3).
- **Country list:** complete list of mandatory formats per country with sources (5.2).
- **Test data:** licence review of official example files per source (5.3).
- **Germany, retention:** exact requirements for retaining the structured part of an e-invoice (5.4).
- **MLS:** suitability for long-term access, member removal and key recovery (6.5).
- **Relays:** interest of public bodies and the legal framework for running relays (6.6).
- **ELSTER/ERiC:** conditions for integrating ERiC into an open implementation (7).
- **Bindings:** which language bindings the reference library offers first (8).
- **falkOSS:** status of the incorporation and of the non-profit recognition at publication (9.3).
- **Governance:** which body and which process for a later transfer (9.3).

## Sources

1. Directive 2014/55/EU on electronic invoicing in public procurement –
   <https://eur-lex.europa.eu/eli/dir/2014/55/oj>
2. European Commission, European legislation on eInvoicing (EN 16931, syntaxes UBL and CII) –
   <https://ec.europa.eu/digital-building-blocks/sites/display/DIGITAL/European+legislation+on+eInvoicing>
3. OpenPeppol, Peppol BIS Billing 3.0 – <https://docs.peppol.eu/poacc/billing/3.0/bis/>
4. Agenzia delle Entrate, La fattura elettronica –
   <https://www.agenziaentrate.gov.it/portale/web/guest/aree-tematiche/fatturazione-elettronica/guida-fatturazione-elettronica/la-fattura-elettronica>
5. Ministry of Finance of Poland, KSeF – scope of mandatory KSeF –
   <https://ksef.podatki.gov.pl/informacje-ogolne-ksef-20/zakres-obowiazkowego-ksef/>
6. Real Decreto 1007/2023 (Reglamento VERI\*FACTU), BOE-A-2023-24840 –
   <https://www.boe.es/diario_boe/txt.php?id=BOE-A-2023-24840>
7. Agencia Tributaria, FAQ VERI\*FACTU – Huella o «hash» –
   <https://sede.agenciatributaria.gob.es/Sede/iva/sistemas-informaticos-facturacion-verifactu/preguntas-frecuentes/huella-hash.html>
8. Ministère de l'Économie, Tout savoir sur la facturation électronique pour les entreprises –
   <https://www.economie.gouv.fr/tout-savoir-sur-la-facturation-electronique-pour-les-entreprises>
9. Bundesministerium der Finanzen, Fragen und Antworten zur Einführung der obligatorischen E-Rechnung –
   <https://www.bundesfinanzministerium.de/Content/DE/FAQ/e-rechnung.html>
10. Council Directive (EU) 2025/516 (VAT in the Digital Age) – <https://eur-lex.europa.eu/eli/dir/2025/516/oj>
11. European Commission, VAT in the Digital Age (ViDA) –
    <https://taxation-customs.ec.europa.eu/taxation/vat/vat-digital-age-vida_en>
12. OECD, Guidance Note: Standard Audit File – Tax, Version 2.0 (2010) –
    <https://web-archive-storage.oecd.org/aemint-web-archive-prod/web-archive/31/319f3ea18d49a9a849ac736cc1cb6b6325080f23fcee60705509cf6b00a8af4e.pdf>
13. Skatteetaten, SAF-T Financial –
    <https://www.skatteetaten.no/en/business-and-organisation/start-and-run/best-practices-accounting-and-cash-register-systems/saf-t-financial/>
14. ISO 20022, Message Definition Report, Bank-to-Customer Cash Management (camt) –
    <https://www.iso20022.org/sites/default/files/2020-12/ISO20022_MDRPart2_BankToCustomerCashManagement_2020_2021_v1_ForSEGReview.pdf>
15. Commission Delegated Regulation (EU) 2019/815 (ESEF) – <https://eur-lex.europa.eu/eli/reg_del/2019/815/oj>
16. § 5b Einkommensteuergesetz – <https://www.gesetze-im-internet.de/estg/__5b.html>
17. Federal tax administration, E-Bilanz and XBRL taxonomies – <https://www.esteuer.de>
18. Autorité des normes comptables, Plan comptable général (consolidated, 1 January 2026) –
    <https://www.anc.gouv.fr/files/anc/files/1_Normes_fran%C3%A7aises/Plans%20comptables/2026/PCG--1er-janvier-2026.pdf>
19. Council Directive 2006/112/EC (VAT Directive), Article 226 – <https://eur-lex.europa.eu/eli/dir/2006/112/oj>
20. Logical Physical Clocks and Consistent Snapshots in Globally Distributed Databases (technical report, 2014) –
    <https://www.cse.buffalo.edu/~demirbas/publications/hlc.pdf>
21. RFC 9420, The Messaging Layer Security (MLS) Protocol (July 2023) – <https://www.rfc-editor.org/rfc/rfc9420>
22. ELSTER, information for software developers (ERiC) – <https://www.elster.de/eportal/infoseite/entwickler>
23. Creative Commons Attribution 4.0 International – <https://creativecommons.org/licenses/by/4.0/>
24. MIT License (SPDX) – <https://spdx.org/licenses/MIT.html>
25. ISO 4217, Currency codes – <https://www.iso.org/iso-4217-currency-codes.html>
26. RFC 8785, JSON Canonicalization Scheme (JCS) (June 2020) – <https://www.rfc-editor.org/rfc/rfc8785>
