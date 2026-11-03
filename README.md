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

For a visible browser add `--variable HEADLESS:False` to the Robot command. Robot reports, logs and failure screenshots are written under `results/`; keep them when investigating a failure. The test targets the public production storefront, so availability, prices, consent screens and bot protection can change independently of the test.

## Static analysis and formatting

Robocop is installed with the project requirements and reads `robocop.toml` from the project root. Run these commands from that directory:

```powershell
# Check Robot Framework files for lint violations
.\.venv\Scripts\robocop.exe check tests resources

# Check formatting without changing files, then apply formatting
.\.venv\Scripts\robocop.exe format --check tests resources
.\.venv\Scripts\robocop.exe format tests resources
```

The check commands return a nonzero exit code when they find issues. The existing Robot files have lint and formatting findings; review the reported changes before applying the formatter.

## Decisions and scope

- A fresh anonymous context, fixed 1440 × 900 desktop viewport and `de-DE` locale are used for each test. The empty basket is verified rather than clearing existing user data. Each add is verified in the basket before continuing.
- “Website price” means the current selling price in the matching PZN search suggestion. It is compared exactly, as `Decimal`, with the basket line total for the same PZN at quantity 1. Reference prices, price per litre, shipping and totals are excluded. The test captures the price at runtime rather than using a fixed expected amount. The parser intentionally accepts a single `€ 4,99` style amount and rejects ambiguous text.
- Product identity is checked on the product page and in a basket row scoped by `data-pzn`. QA attributes are preferred where available. The search price uses a specific descendant of the price container because the latter also contains the price per litre.
- The test clicks the quantity increase once, then checks the value with Browser's bounded retrying assertion. Repeating the state-changing click could increment twice. A price mismatch fails before checkout and records both raw and normalized values.
- Clicking checkout from the populated basket was observed to reach `/nx/login/?targetPageCode=checkoutAddress`. The test verifies that route and visible authentication components, without entering credentials.
- Teardown attempts a screenshot on failure before closing the context. Artifact collection cannot replace the original failure. The Robot log shows the failed keyword and URL; a failed test requires investigation and is not by itself proof of a product defect.

## Challenges and assumptions

The assignment does not define which website price to compare; the search suggestion is the working interpretation. Basket totals are only equivalent to unit price when the quantity is one. This test is scoped to the German site and current DOM, not all locales. Product availability, asynchronous updates, consent overlays and anti-bot checks can prevent a valid run. The automation does not bypass security controls. Browser contexts isolate local browser state; the empty-basket assertion checks the observable guest state. Selectors may need maintenance if the storefront changes.

## Presenting the solution

Explain the business flow in `tests/e2e/checkout.robot`, the locally returned price values, and the component resources. Show a Robot log for a run, then describe why the parser rejects combined prices, why the increment action is not retried, and how a fresh context and failure screenshot aid repeatability and diagnosis.

## Execution record

On 2026-11-03, with the versions above, the three parser unit tests passed. Two consecutive complete runs in fresh contexts passed: the current suggestion price and the quantity-one line total were both EUR 4.99, and checkout reached the authentication route. These values describe those runs, not future expectations. A temporary Robot check also confirmed that the Python keyword returns `Decimal` to Robot.

Two temporary negative runs deliberately changed an expected quantity and a normalized price. Both failed at the intended assertion before checkout; screenshots were saved. The synthetic price mismatch was injected after reading the real basket price, so its raw and injected normalized values intentionally differ. Earlier exploratory runs exposed navigation and quantity-control timing issues that were corrected before the two passing runs. A fresh run can still fail for environmental or storefront changes.
