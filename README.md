# Robot Framework: guest checkout UI test

One end-to-end test for the German storefront using Robot Framework and Browser (Playwright). It searches by PZN, adds each requested product once, increments ibuprofen in the basket, compares the panthenol price, then stops at authentication without signing in or submitting an order.

## Setup and run

Tested on Windows with Python 3.14.0 and Node.js 24.11.1. Browser Library uses Node.js; the setup below installs its matching Playwright browser. Internet access is required for installation and execution.

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install -r requirements.txt
.\.venv\Scripts\rfbrowser init chromium
.\.venv\Scripts\python -m pytest -q
.\.venv\Scripts\python -m robot --outputdir results tests
```

For a visible browser add `--variable HEADLESS:False` to the Robot command. Robot reports, logs, failure screenshots, and Playwright traces are written under `results/`; keep them when investigating a failure. The test targets the public production storefront, so availability, prices, consent screens and bot protection can change independently of the test.

Each test context records a Playwright trace. After the run, open the ZIP file under `results/browser/traces/` with:

```powershell
.\.venv\Scripts\rfbrowser show-trace results\browser\traces\trace_context=<context-id>.zip
```

Replace `<context-id>` with the trace filename in that folder. The trace contains browser actions and page snapshots and helps diagnose timing and locator failures. Traces are retained for passing and failing runs; review them for page content before sharing.

## Main layers

- **Test flow — `tests/e2e/checkout.robot`:** describes the scenario as readable steps and calls keywords.
- **Shared setup — `resources/common.resource`:** opens and closes the browser session; imports the feature resources.
- **Feature keywords — `resources/search.resource`, `product.resource`, `basket.resource`, `checkout.resource`:** group reusable actions by area.
- **Library setup — `resources/libraries.resource`:** imports Browser Library and the project’s Python library.
- **Python logic — `libraries/prices.py`:** parses euro prices into `Decimal`; unit tests are in `tests/unit/test_prices.py`.

Robot connects these layers through imports: the test calls resource keywords, which use Browser Library or the Python keyword. Setup runs before the scenario; teardown runs afterward, including on failure.
## Static analysis and formatting

Robocop is installed with the project requirements and reads `robocop.toml` from the project root. Run these commands from that directory:

```powershell
# Check Robot Framework files for lint violations
.\.venv\Scripts\robocop.exe check tests resources

# Check formatting without changing files, then apply formatting
.\.venv\Scripts\robocop.exe format --check tests resources
.\.venv\Scripts\robocop.exe format tests resources
```

The check commands return a nonzero exit code when they find issues. The lint check should be clean. Apply formatting, then rerun both checks before sharing the project.

## Decisions and scope

- A fresh anonymous context, fixed 1440 × 900 desktop viewport and `de-DE` locale are used for each test. The empty basket is verified rather than clearing existing user data. Each product identity is verified before adding; both quantities are checked in the basket.
- “Website price” means the current selling price in the matching PZN search suggestion. It is compared exactly, as `Decimal`, with the basket line total for the same PZN at quantity 1. Reference prices, price per litre, shipping and totals are excluded. The test captures the price at runtime rather than using a fixed expected amount. The parser intentionally accepts a single `€ 4,99` style amount and rejects ambiguous text.
- Product identity is checked on the product page and in a basket row scoped by `data-pzn`. QA attributes are preferred where available. The search price uses a specific descendant of the price container because the latter also contains the price per litre.
- The test checks the starting basket quantity, clicks the increase control once, and verifies the increment with Browser's bounded retrying assertion. Repeating the state-changing click could increment twice. The scenario compares prices itself and logs raw and normalized values; a mismatch fails before checkout.
- Clicking checkout from the populated basket was observed to reach `/nx/login/?targetPageCode=checkoutAddress`. The test verifies that route and visible authentication components, without entering credentials.
- Teardown attempts a screenshot on failure before closing the context. Artifact collection cannot replace the original failure. The Robot log shows the failed keyword and URL; a failed test requires investigation and is not by itself proof of a product defect.

## Challenges and assumptions

The assignment does not define which website price to compare; the search suggestion is the working interpretation. Basket totals are only equivalent to unit price when the quantity is one. This test is scoped to the German site and current DOM, not all locales. Product availability, asynchronous updates, consent overlays and anti-bot checks can prevent a valid run. The automation does not bypass security controls. Browser contexts isolate local browser state; the empty-basket assertion checks the observable guest state. Selectors may need maintenance if the storefront changes.

## Execution record

Earlier exploratory runs exposed navigation and quantity-control timing issues that were corrected before the two passing runs. A fresh run can still fail for environmental or storefront changes.
