# US Sales & Use Tax Keyed by ZIP Code - Mechanics Layer

*For an AI-accountant knowledgebase. All rates labeled approximate and "as of 2026." Rates change frequently (often quarterly) and a single ZIP can span multiple jurisdictions, so treat every per-ZIP rate as a default/best-effort that must be confirmed by rooftop geocode for legal-grade accuracy.*

## 1. How US sales tax jurisdiction works (the "rate stack")

A US sales tax rate at any given delivery point is a **sum of independent layers**:

| Layer | Levied by | Examples |
|---|---|---|
| **State** | State legislature | CA 7.25%, NY 4.00%, TX 6.25% |
| **County / parish / borough** | County government | Cook County (IL), Orleans Parish (LA) |
| **City / municipality** | City government | Chicago city tax, NYC local tax |
| **Special districts** | Voter-approved local authorities | Transit (RTD Denver, RTA Chicago), stadium districts, tourism/resort, library, hospital, fire, "transportation improvement" districts |

The **combined rate** = state + county + city + every overlapping special district that the specific point falls inside. Because special districts are drawn for their own purposes (a transit district follows rail corridors, a stadium district follows a funding boundary), they do **not** align with city or county lines, and several can overlap a single street.

**Why a ZIP code does NOT map cleanly to one tax rate:**

- **ZIPs are USPS delivery-route constructs, not areas.** Per USPS Publication 28, ZIP codes "do not represent fixed geographic boundaries. They identify the mail delivery routes assigned to a particular address." There is no authoritative polygon; the Census Bureau only approximates them as ZCTAs (ZIP Code Tabulation Areas).
- **ZIPs routinely straddle jurisdiction lines.** A single 5-digit ZIP can cross multiple cities, counties, and special districts. (Avalara's canonical example: ZIP 30052 in Georgia spans areas in **four** counties, each with a different rate.) Two houses across the street from each other can owe different combined rates.
- **The legally correct lookup is: address → rooftop geocode (lat/long) → which jurisdiction polygons contain that point → sum their rates.** This is "rooftop" or "geolocation" accuracy.
- **ZIP+4 (9-digit) is a closer approximation than 5-digit ZIP** because it narrows to a block-face / small delivery segment, which usually sits inside a single jurisdiction set. It is still an approximation, not a guarantee. The Streamlined Sales Tax (SST) boundary files are explicitly keyed by **either 5-digit or 9-digit ZIP** for this reason, and some SST states key by actual address instead.

**Practical rule for the agent:** store a per-ZIP default combined rate for estimation and UX, but for invoices/returns resolve to full address + rooftop geocode (or a certified rate engine). Treat 5-digit ZIP rates as "good enough to quote, not to remit."

## 2. The 5 NOMAD states (no statewide sales tax)

**NOMAD** = **N**ew Hampshire, **O**regon, **M**ontana, **A**laska, **D**elaware. None levy a statewide sales tax (state rate = 0.00%).

| State | State rate | Local sales tax? | ZIP-lookup implication |
|---|---|---|---|
| **New Hampshire** | 0% | None | Every ZIP = 0% sales tax |
| **Oregon** | 0% | None | Every ZIP = 0% (e.g., 97201 Portland) |
| **Montana** | 0% | **Limited** - resort/tourism towns may levy a local "resort tax" (e.g., Whitefish, West Yellowstone, Big Sky) | Most ZIPs = 0%, but a handful of resort-town ZIPs carry a local rate |
| **Alaska** | 0% | **Yes** - 100+ municipalities/boroughs levy local sales tax (up to ~7.5%); many now collect remote sales tax via the **Alaska Remote Seller Sales Tax Commission (ARSSTC)** | ZIP rate is purely local; Anchorage = 0%, but Wasilla/Juneau/Kodiak ≠ 0% |
| **Delaware** | 0% | None (has a **gross receipts tax** on sellers instead, not a buyer-facing sales tax) | Every ZIP = 0% sales tax (e.g., 19901 Dover) |

**Key nuance for the knowledgebase:** "No state sales tax" ≠ "no tax anywhere." In **Alaska and Montana**, a correct ZIP lookup must still resolve the *local* jurisdiction. In NH, OR, DE the answer is reliably 0%.

## 3. Origin- vs destination-based sourcing (which ZIP's rate applies)

- **Destination-based (the majority + Washington DC):** the rate at the **buyer's ship-to address** applies. The relevant ZIP is the **destination** ZIP. This is the default for nearly all interstate remote sales.
- **Origin-based (~12 states for *intrastate* sales):** when both seller and buyer are in the same state, the rate at the **seller's location** (origin ZIP) applies. Major origin-based states include **Texas, Pennsylvania, Ohio, Virginia, Tennessee, Utah, Missouri, Illinois (intrastate), Arizona, New Mexico (mixed)**.
- **Mixed / hybrid cases the agent must handle:**
  - **California** - state/county/city portions are *origin*-based, but **district taxes are destination-based**. So a CA sale uses the origin ZIP for the base 7.25% but the destination ZIP for any district add-on.
  - **Illinois** - in-state sellers with "predominant selling activity" in IL use origin rules; **remote/out-of-state sellers must use destination** rules (and IL retailers' occupation tax rules tightened for 2026).
  - **New Mexico** - switched from origin to **destination**-based effective July 1, 2021.
- **Remote interstate sales are essentially always destination-based**, regardless of whether the state is "origin" for intrastate transactions. Origin sourcing applies to in-state sellers shipping in-state.

**Rule for the agent:** if seller-state ≠ buyer-state → use the **destination** ZIP. If same-state and the state is origin-based → use the **seller/origin** ZIP (and remember CA's district carve-out).

## 4. Economic nexus post-*Wayfair* (high level)

*South Dakota v. Wayfair* (2018) let states require **out-of-state sellers with no physical presence** to collect sales tax once they cross an **economic** threshold.

- **Typical threshold:** **$100,000 in sales OR 200 transactions** in the state in the current/prior year. (South Dakota's original $100k / 200 standard became the template.)
- **The transaction-count test is being abandoned.** As of Jan 1, 2026, **16+ states** have dropped the 200-transaction prong and now use a revenue threshold only. Recent examples: **Alaska** repealed the 200-transaction test (effective Jan 1, 2025), **Illinois** dropped it Jan 1, 2026, and **Kentucky** removes it Aug 1, 2026. Some larger states use a higher revenue figure (e.g., $500k in CA, NY, TX).
- **Marketplace facilitator rules (high level):** essentially **all states with a sales tax now require the marketplace** (Amazon, eBay, Etsy, Walmart, etc.) to **calculate, collect, and remit** sales tax on behalf of its third-party sellers. Implications:
  - Sales **made through the marketplace** are handled by the platform; the individual seller generally doesn't collect on those.
  - The seller is still responsible for **direct/off-marketplace channels** (own website, trade shows, physical store).
  - Marketplace-facilitated sales **may still count toward the seller's own economic-nexus thresholds** in some states (affecting their direct-sale obligations).

## 5. Use tax (when the buyer owes)

Use tax is the complement to sales tax: it applies when a **taxable item is used/stored/consumed in a state but sales tax wasn't collected at purchase** (e.g., bought tax-free out of state or from a non-collecting remote seller). It prevents avoidance by buying across borders. Two flavors:

| Type | Who remits | When it applies |
|---|---|---|
| **Seller use tax** (a.k.a. "retailer's use tax") | The **seller** collects from the buyer and remits | An **out-of-state seller** with nexus collects on an **interstate** sale into the state. Functionally identical to sales tax; just a different label/return line for remote sellers. |
| **Consumer use tax** | The **buyer** self-assesses and remits directly to the state | The seller **did not collect** any tax. The buyer (business or individual) owes use tax on the purchase price, typically at the **destination/use-location** combined rate. Common on business equipment, drop-ships, and out-of-state purchases. |

**Key point:** the distinction is **who is responsible for remitting**, not where the parties sit. Consumer use tax shifts the duty to the buyer; it does **not** appear on an invoice and must be self-reported (often on a use-tax line of a sales-tax return or an individual income-tax return). For an AI accountant: flag uncollected-tax purchases as **consumer use tax accruals**, computed at the buyer's location's combined rate.

## 6. Authoritative data sources to populate per-ZIP rates at scale

To cover all ~42,000 ZIPs without hand-research, layer these:

| Source | What it gives | URL |
|---|---|---|
| **Streamlined Sales Tax (SST) Rate & Boundary Files** | For each ~24 SST member states: a **boundary file** keyed by 5- or 9-digit ZIP (or address) → tax codes, plus a **rate file** → rate per code. **Updated quarterly** (posted by the 1st of the month before each quarter). Free. Single-rate states unchanged since Oct 1, 2006 are exempt from posting. | https://www.streamlinedsalestax.org/Shared-Pages/rate-and-boundary-files |
| **State Departments of Revenue rate tables** | Non-SST states publish their own downloadable rate charts (often CSV/PDF). E.g., Oklahoma Tax Commission rate-by-city/county PDFs; Arizona DOR TPT rate table; City of Phoenix combined-rate page; Washington DOR rate lookup/downloads. | (per-state DOR sites; see Sources) |
| **Census ZCTA ↔ County Relationship File** | Maps each ZCTA (ZIP approximation) to the county/counties it intersects - essential for assigning county-level rates and detecting multi-county ZIPs. File: `tab20_zcta520_county20_natl.txt`. | https://www.census.gov/geographies/reference-files/time-series/geo/relationship-files.2020.html |
| **HUD-USPS ZIP Code Crosswalk Files** | Quarterly ZIP→county / tract / CBSA / congressional-district crosswalks **with allocation ratios** (residential/business/total), letting you weight a ZIP that spans multiple counties. Back to 2010. | https://www.huduser.gov/portal/datasets/usps_crosswalk.html |
| **Commercial rate APIs (rooftop accuracy)** | Address → rooftop geocode → exact combined rate + product taxability + filing. Use for legal-grade calculation and remittance. | Avalara AvaTax: https://www.avalara.com/ • TaxJar (Stripe): https://www.taxjar.com/ • Vertex: https://www.vertexinc.com/ |
| **TaxCloud / free SST-backed calculators** | Free or low-cost SST-certified rate lookups | https://taxcloud.com/sales-tax-calculator/ |

**Scaling recipe:**
1. Pull SST rate+boundary files for member states (covers most of the country at ZIP/ZIP+4).
2. For non-SST states, pull each state DOR's published rate table.
3. Use the **Census ZCTA→County** + **HUD ZIP crosswalk** to map ambiguous ZIPs to their candidate counties and flag multi-jurisdiction ZIPs (store a "spans N jurisdictions" warning).
4. Refresh **quarterly** (most rate changes land on quarter boundaries).
5. For anything you actually invoice/remit, call a **rooftop API** rather than the ZIP table.

## 7. Seed dataset - ~19 representative ZIPs (approximate, as of 2026)

Rates are the commonly published combined rates for the ZIP's primary jurisdiction. Each ZIP may contain addresses with different rates. State rates from Tax Foundation 2026; combined rates cross-checked against Avalara/SalesTaxHandbook 2026 city pages.

| ZIP | City | County/Parish | State | State rate | Local (approx) | Combined (approx) |
|---|---|---|---|---|---|---|
| 10001 | New York | New York | NY | 4.000% | 4.875% (4.5% city + 0.375% MCTD) | 8.875% |
| 90012 | Los Angeles | Los Angeles | CA | 7.250% | 2.500% | 9.750% |
| 60601 | Chicago | Cook | IL | 6.250% | 4.000% | 10.250% |
| 77002 | Houston | Harris | TX | 6.250% | 2.000% | 8.250% |
| 33131 | Miami | Miami-Dade | FL | 6.000% | 1.000% | 7.000% |
| 98101 | Seattle | King | WA | 6.500% | 3.750% | 10.250% |
| 19901 | Dover | Kent | DE | 0.000% | 0.000% | 0.000% |
| 97201 | Portland | Multnomah | OR | 0.000% | 0.000% | 0.000% |
| 33480 | Palm Beach | Palm Beach | FL | 6.000% | 0.500% | 6.500% |
| 80202 | Denver | Denver | CO | 2.900% | 6.250% | 9.150% |
| 30303 | Atlanta | Fulton | GA | 4.000% | 4.900% | 8.900% |
| 02108 | Boston | Suffolk | MA | 6.250% | 0.000% | 6.250% |
| 85001 | Phoenix | Maricopa | AZ | 5.600% | 3.500% | 9.100% |
| 73102 | Oklahoma City | Oklahoma | OK | 4.500% | 4.125% | 8.625% |
| 70112 | New Orleans | Orleans Parish | LA | 5.000% | 5.000% | 10.000% |
| 87501 | Santa Fe | Santa Fe | NM | 4.875% | 3.3125% | 8.1875% |
| 89101 | Las Vegas | Clark | NV | 6.850% | 1.525% | 8.375% |
| 99501 | Anchorage | Anchorage Muni | AK | 0.000% | 0.000% | 0.000% |
| 02903 | Providence | Providence | RI | 7.000% | 0.000% | 7.000% |

```json
[
  {"zip": "10001", "city": "New York", "county": "New York", "state": "NY", "state_rate": 4.000, "local_rate_approx": 4.875, "combined_rate_approx": 8.875, "note": "NYC: 4.5% city + 0.375% MCTD transit surcharge on top of 4% state. Destination-based. Uniform across NYC ZIPs."},
  {"zip": "90012", "city": "Los Angeles", "county": "Los Angeles", "state": "CA", "state_rate": 7.250, "local_rate_approx": 2.500, "combined_rate_approx": 9.750, "note": "CA is mixed-sourcing: state/county/city origin-based, district taxes destination-based. LA County district add-ons push downtown LA to ~9.75%; other LA-county ZIPs differ."},
  {"zip": "60601", "city": "Chicago", "county": "Cook", "state": "IL", "state_rate": 6.250, "local_rate_approx": 4.000, "combined_rate_approx": 10.250, "note": "Cook County + Chicago + RTA transit district stack to 10.25%, among the highest big-city rates. IL intrastate origin-based; remote sellers destination-based (2026 rules tightened)."},
  {"zip": "77002", "city": "Houston", "county": "Harris", "state": "TX", "state_rate": 6.250, "local_rate_approx": 2.000, "combined_rate_approx": 8.250, "note": "TX caps local add-ons at 2.0% (city 1% + Houston MTA transit 1%). TX is origin-based for intrastate sales. 8.25% is the statewide max."},
  {"zip": "33131", "city": "Miami", "county": "Miami-Dade", "state": "FL", "state_rate": 6.000, "local_rate_approx": 1.000, "combined_rate_approx": 7.000, "note": "FL 6% state + Miami-Dade 1% discretionary surtax. FL surtax applies to first $5,000 of a single tangible item on some categories. Destination-based."},
  {"zip": "98101", "city": "Seattle", "county": "King", "state": "WA", "state_rate": 6.500, "local_rate_approx": 3.750, "combined_rate_approx": 10.250, "note": "WA 6.5% state + King County/Seattle + Sound Transit RTA district = ~10.25-10.35%. Destination-based. Some downtown blocks carry extra stadium/transit add-ons."},
  {"zip": "19901", "city": "Dover", "county": "Kent", "state": "DE", "state_rate": 0.000, "local_rate_approx": 0.000, "combined_rate_approx": 0.000, "note": "NOMAD state. No sales or use tax for buyers. DE instead levies a seller-side gross receipts tax. Every DE ZIP = 0%."},
  {"zip": "97201", "city": "Portland", "county": "Multnomah", "state": "OR", "state_rate": 0.000, "local_rate_approx": 0.000, "combined_rate_approx": 0.000, "note": "NOMAD state. No state or local sales tax anywhere in OR. Every OR ZIP = 0%."},
  {"zip": "33480", "city": "Palm Beach", "county": "Palm Beach", "state": "FL", "state_rate": 6.000, "local_rate_approx": 0.500, "combined_rate_approx": 6.500, "note": "FL 6% + Palm Beach County 0.5% surtax. Lower than Miami-Dade. FL county surtaxes vary widely (0%-1.5%), so FL ZIP rates differ by county."},
  {"zip": "80202", "city": "Denver", "county": "Denver", "state": "CO", "state_rate": 2.900, "local_rate_approx": 6.250, "combined_rate_approx": 9.150, "note": "CO has the lowest state rate (2.9%) but heavy local stacking: Denver city + RTD transit + cultural facilities district. CO is a notorious home-rule/multi-jurisdiction state; ZIP rates are especially unreliable here."},
  {"zip": "30303", "city": "Atlanta", "county": "Fulton", "state": "GA", "state_rate": 4.000, "local_rate_approx": 4.900, "combined_rate_approx": 8.900, "note": "GA 4% + Fulton County LOST/SPLOST + Atlanta MARTA transit + city add-ons = ~8.9%. GA ZIPs frequently span multiple counties (classic multi-jurisdiction problem)."},
  {"zip": "02108", "city": "Boston", "county": "Suffolk", "state": "MA", "state_rate": 6.250, "local_rate_approx": 0.000, "combined_rate_approx": 6.250, "note": "MA has NO local sales taxes; the 6.25% state rate is uniform statewide. One of the few states where ZIP = state rate everywhere. (Meals tax is separate.)"},
  {"zip": "85001", "city": "Phoenix", "county": "Maricopa", "state": "AZ", "state_rate": 5.600, "local_rate_approx": 3.500, "combined_rate_approx": 9.100, "note": "AZ 5.6% state + Maricopa County 0.7% + Phoenix city TPT. Phoenix raised its city rate ~0.5% (8.6% -> 9.1%) effective Oct 2025, so 9.1% is the current 2026 combined rate. AZ uses Transaction Privilege Tax (seller-side), origin/special sourcing."},
  {"zip": "73102", "city": "Oklahoma City", "county": "Oklahoma", "state": "OK", "state_rate": 4.500, "local_rate_approx": 4.125, "combined_rate_approx": 8.625, "note": "OK 4.5% state + Oklahoma County + OKC city. OK allows local option up to ~6.5%; OKC combined ~8.625%. OK ZIPs cross county lines often. Verify against OK Tax Commission quarterly rate charts."},
  {"zip": "70112", "city": "New Orleans", "county": "Orleans Parish", "state": "LA", "state_rate": 5.000, "local_rate_approx": 5.000, "combined_rate_approx": 10.000, "note": "LA has the highest average combined US rate (~10.1%). Orleans Parish local ~5% on top of 5% state = ~10%. LA local sales tax is administered at the parish level, making rooftop accuracy especially important."},
  {"zip": "87501", "city": "Santa Fe", "county": "Santa Fe", "state": "NM", "state_rate": 4.875, "local_rate_approx": 3.3125, "combined_rate_approx": 8.1875, "note": "NM uses a Gross Receipts Tax (GRT), now destination-based (since Jul 1, 2021). State portion 4.875% + Santa Fe city/county = ~8.19%. NM rates use 4-decimal precision and change frequently."},
  {"zip": "89101", "city": "Las Vegas", "county": "Clark", "state": "NV", "state_rate": 6.850, "local_rate_approx": 1.525, "combined_rate_approx": 8.375, "note": "NV 6.85% state (includes mandatory statewide LSST/BCCRT components) + Clark County add-ons = 8.375%. Clark County (Las Vegas) is NV's highest. Destination-based."},
  {"zip": "99501", "city": "Anchorage", "county": "Anchorage Municipality", "state": "AK", "state_rate": 0.000, "local_rate_approx": 0.000, "combined_rate_approx": 0.000, "note": "NOMAD state: no AK state sales tax. Anchorage levies NO local sales tax = 0%. BUT 100+ other AK localities DO (up to ~7.5%, e.g., Juneau, Wasilla, Kodiak), often collected via the ARSSTC remote-seller commission. AK ZIP rate is purely local."},
  {"zip": "02903", "city": "Providence", "county": "Providence", "state": "RI", "state_rate": 7.000, "local_rate_approx": 0.000, "combined_rate_approx": 7.000, "note": "RI has NO local sales tax; 7% state rate is uniform statewide (like MA). Included as a second 'state-rate-equals-ZIP-rate' example. Destination-based."}
]
```

## Sources

- Avalara - *ZIP Codes: The wrong tool for determining tax rates*: https://www.avalara.com/us/en/learn/whitepapers/zip-codes-the-wrong-tool-for-the-job.html
- Avalara - *Getting the Right Sales Tax Rate: ZIP Codes vs. Geolocation*: https://www.avalara.com/us/en/blog/2015/08/getting-the-right-sales-tax-rate-zip-codes-vs-geolocation-wills-whiteboard.html
- TaxJar - *Why five-digit ZIP codes don't always return correct sales tax rates*: https://www.taxjar.com/blog/calculations/zip-codes-sales-tax
- Autoaddress - *What are ZIP Codes (and why ZIP+4 matters for deliveries & sales tax)*: https://autoaddress.com/articles/what-are-zip-codes-and-why-zip4-matters-for-deliveries-sales-tax/
- Tax Foundation - *2026 Sales Tax Rates / Sales Taxes by State*: https://taxfoundation.org/data/all/state/sales-tax-rates/
- Avalara - *Which states have no sales tax?*: https://www.avalara.com/blog/en/north-america/2022/09/states-with-no-sales-tax-what-you-need-to-know.html
- Taxually - *The NOMAD States*: https://www.taxually.com/blog/the-nomad-states-which-us-states-have-no-sales-tax
- Alaska Remote Seller Sales Tax Commission - *Tax Rates*: https://arsstc.org/business-sellers/tax-rates/
- TaxJar - *Origin-based and destination-based sales tax rates*: https://www.taxjar.com/sales-tax/origin-based-and-destination-based-sales-tax
- Avalara - *U.S. states with origin sourcing or special sourcing rules*: https://knowledge.avalara.com/bundle/dqa1657870670369_dqa1657870670369/page/U.S._states_with_origin_sourcing_or_special_sourcing_rules.html
- Sales Tax Institute - *Economic Nexus State Guide*: https://www.salestaxinstitute.com/resources/economic-nexus-state-guide
- Sales Tax Institute - *South Dakota v. Wayfair FAQ*: https://www.salestaxinstitute.com/sales_tax_faqs/wayfair-economic-nexus
- Avalara - *States eliminating economic nexus transaction thresholds (2025)*: https://www.avalara.com/blog/en/north-america/2025/06/states-eliminating-economic-nexus-transaction-thresholds.html
- Avalara - *State-by-state guide to marketplace facilitator laws*: https://www.avalara.com/us/en/learn/guides/state-by-state-guide-to-marketplace-facilitator-laws.html
- Thomson Reuters - *Sales tax vs. use tax: the differences*: https://tax.thomsonreuters.com/blog/sales-tax-vs-use-tax-the-differences/
- Vertex - *Defining Sales Tax, Sellers Use Tax & Consumer Use Tax*: https://www.vertexinc.com/resources/resource-library/defining-sales-tax-sellers-use-tax-and-consumer-use-tax
- Streamlined Sales Tax Governing Board - *Rate and Boundary Files*: https://www.streamlinedsalestax.org/Shared-Pages/rate-and-boundary-files
- US Census Bureau - *2020 Relationship Files (ZCTA to County)*: https://www.census.gov/geographies/reference-files/time-series/geo/relationship-files.2020.html
- US Census Bureau - *Explanation of the 2020 ZCTA to County Relationship File*: https://www2.census.gov/geo/pdfs/maps-data/data/rel2020/zcta520/explanation_tab20_zcta520_county20_natl.pdf
- HUD USER - *USPS ZIP Code Crosswalk Files*: https://www.huduser.gov/portal/datasets/usps_crosswalk.html
- City of Phoenix - *Current Combined Tax Rates (Phoenix, State, County)*: https://www.phoenix.gov/administration/departments/finance/privilege-sales-use-tax/about-tpt-use-tax/current-combined-tax-rates-phoenix-state-county.html
- Oklahoma Tax Commission - *Rates and Codes for Sales, Use, and Lodging Tax (2026)*: https://oklahoma.gov/content/dam/ok/en/tax/documents/resources/publications/businesses/sales-and-use-tax/rate-charts-copos/2026/copo1Q26.pdf
- SalesTaxHandbook - city rate pages (Atlanta, Boston, Phoenix, Las Vegas, Santa Fe, Palm Beach, Denver), 2026: https://www.salestaxhandbook.com/
- Avalara - 2026 city/ZIP rate pages (Miami, Denver, Santa Fe, Las Vegas, Anchorage, Palm Beach, ZIP 33480): https://www.avalara.com/us/en/taxrates/state-rates.html

---
