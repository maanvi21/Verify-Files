# 🔗 Decentralized File Hash Verification System

A blockchain-based system to **register** and **verify** the integrity of files using SHA-256 hashes stored on the Ethereum blockchain.

For copy-paste local setup and run commands, see [RUN_GUIDE.md](RUN_GUIDE.md). Truffle now writes deployed contract addresses to `frontend/contract-config.js` automatically.

---

## 📁 Project Structure

```
blockchain proj/
├── contracts/
│   └── FileHashVerification.sol    ← Solidity smart contract
├── migrations/
│   └── 1_deploy_contracts.js       ← Truffle deployment script
├── test/
│   └── FileHashVerification.test.js← Automated tests
├── frontend/
│   └── index.html                  ← Web UI (MetaMask + Web3.js)
├── truffle-config.js               ← Truffle configuration
├── package.json
└── README.md
```

---

## 🛠️ Prerequisites

| Tool       | Purpose                            | Download |
|------------|------------------------------------|-|
| **Node.js** (v16+) | JavaScript runtime          | https://nodejs.org |
| **Ganache**  | Local Ethereum blockchain          | https://trufflesuite.com/ganache |
| **MetaMask** | Browser wallet extension           | https://metamask.io |
| **Truffle**  | Smart contract framework           | `npm install -g truffle` |

---

## 🚀 Step-by-Step Setup

### 1. Install Dependencies

```bash
cd "blockchain proj"
npm install
npm install -g truffle
```

### 2. Start Ganache

1. Open **Ganache** (GUI version).
2. Click **"Quickstart"** to create a workspace.
3. Note the **RPC Server** URL — it should be `HTTP://127.0.0.1:7545`.
4. You'll see 10 test accounts, each with 100 ETH.

> If using `ganache-cli` instead, run: `ganache-cli -p 7545`

### 3. Compile & Deploy the Contract

```bash
truffle compile
truffle migrate --network development
```

After migration, you'll see output like:

```
   Deploying 'FileHashVerification'
   --------------------------------
   > contract address:    0xAbCdEf1234567890...
   > block number:        3
   > account:             0x...
```

**Copy the contract address** — you'll need it next.

### 4. Update the Frontend

Open `frontend/index.html` and find this line (~line 177):

```js
const CONTRACT_ADDRESS = "PASTE_YOUR_CONTRACT_ADDRESS_HERE";
```

Replace it with your deployed contract address:

```js
const CONTRACT_ADDRESS = "0xAbCdEf1234567890...";
```

### 5. Connect MetaMask to Ganache

1. Open MetaMask in your browser.
2. Click the network dropdown → **Add Network** → **Add Network Manually**.
3. Enter:
   - **Network Name:** Ganache Local
   - **RPC URL:** `http://127.0.0.1:7545`
   - **Chain ID:** `1337`
   - **Currency Symbol:** ETH
4. Click **Save**.
5. **Import a Ganache account:**
   - In Ganache, click the 🔑 key icon next to any account to copy its private key.
   - In MetaMask → **Import Account** → paste the private key.

### 6. Open the Frontend

Simply open `frontend/index.html` in your browser (double-click it or use Live Server in VS Code).

---

## 🎮 How to Use

### Register a File
1. Click **"Connect MetaMask"** and approve the connection.
2. In the **Register** section, choose a file from your computer.
3. The SHA-256 hash is computed automatically in your browser.
4. Enter a filename (auto-filled from the file you picked).
5. Click **"Register on Blockchain"** → confirm the transaction in MetaMask.

### Verify a File
1. In the **Verify** section, choose a file — or paste a hash manually.
2. Click **"Verify"**.
3. If the hash is found on-chain, you'll see the owner, filename, and timestamp.
4. If not found, you'll be told the hash isn't registered.

### View My Files
Click **"Load My Files"** to see all files you've registered from your current wallet.

---

## ✅ Running Tests

```bash
truffle test
```

Expected output:

```
  Contract: FileHashVerification
    ✓ should register a file hash
    ✓ should NOT allow duplicate registration
    ✓ should verify a registered file
    ✓ should return false for unregistered hash
    ✓ should return user files list
    ✓ should reject empty file name
    ✓ should reject zero hash

  7 passing
```

---

## 🧪 Using Remix IDE (Alternative)

If you prefer **Remix IDE** instead of Truffle:

1. Go to [https://remix.ethereum.org](https://remix.ethereum.org).
2. Create a new file → paste the contents of `contracts/FileHashVerification.sol`.
3. **Compile**: Select Solidity 0.8.19 → click "Compile".
4. **Deploy**:
   - Set Environment to **"Injected Provider - MetaMask"**.
   - Make sure MetaMask is connected to Ganache.
   - Click **Deploy**.
5. Copy the deployed contract address → update `frontend/index.html`.

---

## 📝 Smart Contract Functions

| Function | Type | Description |
|----------|------|-------------|
| `registerFile(hash, name)` | Write | Store a new file hash on-chain |
| `verifyFile(hash)` | Read | Check if a hash is registered + get details |
| `getFileDetails(hash)` | Read | Get owner, name, timestamp for a hash |
| `getUserFiles(address)` | Read | Get all hashes registered by an address |
| `isFileRegistered(hash)` | Read | Simple boolean check |
| `totalFiles()` | Read | Total number of registered files |

---

## 💡 How It Works

```
User selects a file
        │
        ▼
Browser computes SHA-256 hash (client-side, file never leaves your machine)
        │
        ▼
Hash is sent to the smart contract via MetaMask transaction
        │
        ▼
Smart contract stores: { hash → owner, fileName, timestamp }
        │
        ▼
Anyone can later verify a file by computing its hash and querying the contract
```

> **Key point**: The file itself is never uploaded anywhere. Only the 32-byte hash is stored on-chain, making this extremely gas-efficient.

---

## 🔧 Troubleshooting

| Issue | Fix |
|-------|-----|
| MetaMask not connecting | Make sure you're on the Ganache network (Chain ID 1337) |
| "File hash already registered" | That exact file was already registered by someone |
| Transaction reverted | Check Ganache logs; ensure the contract address is correct |
| Truffle compile error | Ensure you have Solidity 0.8.19: `truffle version` |
| Port conflict | Ganache GUI uses 7545; ganache-cli uses 8545 by default |
