OpenGrants Protocol

A Decentralized and Transparent Grant Funding System Built on the Stacks Blockchain

Overview

OpenGrants Protocol is a Clarity-based smart contract that enables transparent, decentralized management of grant funding.  
It empowers communities, organizations, and developers to create,submit, vote, and disburse grants on-chain with full transparency and no intermediaries.

By leveraging the Stacks blockchain, OpenGrants promotes fairness, accountability, and efficiency in how innovation and public-good projects receive funding.

Features

- Grant Creation: Administrators can open new grant pools for specific programs or initiatives.  
- Proposal Submission: Contributors can submit proposals detailing goals, funding amounts, and milestones.  
- Voting System: Community or DAO members can evaluate and vote on proposals.  
- Automated Disbursement: Approved projects automatically receive funding upon milestone verification.  
- On-Chain Transparency: Every grant, proposal, and vote is recorded immutably on the Stacks blockchain.

Smart Contract Structure

Core Functions
| Function | Description |
|-----------|--------------|
| `create-grant` | Initializes a new grant pool with funding details and admin control. |
| `submit-proposal` | Allows users to submit proposals under specific grant pools. |
| `vote-proposal` | Enables community or committee members to vote on proposals. |
| `release-funds` | Transfers funds to approved grantees upon milestone verification. |
| `get-grant-status` | Returns the status and details of a given grant pool or proposal. |

### Key Variables
- `grant-counter` — Tracks the number of grants created.
- `proposal-counter` — Tracks submitted proposals.
- `grants` — A map storing details of each grant.
- `proposals` — A map storing proposal metadata.
- `votes` — A map of voting records for proposals.

Technical Details

- Language: [Clarity]
- Framework: [Clarinet]
- Token Type: STX / SIP-010 compatible tokens
- Deployment Environment: Stacks Testnet / Mainnet ready
- Category: Governance & Public Goods Funding

