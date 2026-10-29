# Run the project: copy-paste steps

Run these steps in order. Use the project folder `C:\Users\maanv\Desktop\blockchain proj` for each PowerShell window. Keep the Ganache and frontend-server windows open while using the app.

## One-time dependency install

In PowerShell:

```powershell
cd "C:\Users\maanv\Desktop\blockchain proj"
npm install
```

## Terminal 1 — start Ganache

Open PowerShell and run:

```powershell
cd "C:\Users\maanv\Desktop\blockchain proj"
npx ganache --server.port 7545 --chain.chainId 1337 --chain.networkId 1337 --wallet.seed "verity-local-dev" --database.dbPath ".\ganache-data"
```

Leave this window open. Continue after it prints `RPC Listening on 127.0.0.1:7545`. The µWS compatibility warning is okay if Ganache starts and prints that line.

## Terminal 2 — deploy the smart contract

Open a second PowerShell window and run:

```powershell
cd "C:\Users\maanv\Desktop\blockchain proj"
npx truffle migrate --network development
```

The migration automatically writes the deployed address to `frontend/contract-config.js`. The UI reads that file, so you do not need to edit an address manually. Do not add `--reset` during normal startup; it forces a new deployment.

## MetaMask — add and select the local network

These are MetaMask clicks, not terminal commands:

1. Open MetaMask **Menu → Networks → Add a custom network**.
2. Enter these values and save:

   | Field | Value |
   | --- | --- |
   | Network name | `Ganache Local` |
   | RPC URL | `http://127.0.0.1:7545` |
   | Chain ID | `1337` |
   | Currency symbol | `ETH` |
   | Block explorer URL | Leave blank |

3. Select **Ganache Local** for this app. Do not use Ethereum Mainnet for the local contract.

## Optional — fund your existing MetaMask account with local test ETH

Skip this if the selected MetaMask account already has Ganache ETH or if you imported a Ganache test account. This sends test ETH only on your local Ganache chain. It does not send real ETH.

In a third PowerShell window, run:

```powershell
cd "C:\Users\maanv\Desktop\blockchain proj"
npx truffle console --network development
```

Wait for the `truffle(development)>` prompt. Enter these lines **at that Truffle prompt**, replacing the example with your MetaMask public address:

```js
const accounts = await web3.eth.getAccounts()
```

```js
await web3.eth.sendTransaction({from: accounts[0], to: "YOUR_METAMASK_PUBLIC_ADDRESS", value: web3.utils.toWei("100", "ether")})
```

Wait for the transaction result, then exit the Truffle console:

```text
.exit
```

Never enter your real wallet private key or recovery phrase in the project or share it. The funding step needs only your public address.

## Terminal 3 — start the frontend

Open another PowerShell window and run:

```powershell
cd "C:\Users\maanv\Desktop\blockchain proj"
py -m http.server 8000 --directory ".\frontend"
```

Leave this window open. In Chrome or Edge with the MetaMask extension, open:

```text
http://localhost:8000
```

Click **Connect wallet** and approve the connection. The page's network status should show Ganache Local, chain ID 1337.

## Use the app

1. To register, choose a file, wait for the SHA-256 fingerprint, and click **Anchor on blockchain**. Confirm in MetaMask.
2. Find registered file details in **Your file registry** in the app. MetaMask displays wallet activity, not file assets.
3. To verify, choose the file again or paste its fingerprint, then click **Verify fingerprint**.

The file itself is never uploaded. The contract stores its fingerprint, filename, owner address, and registration time.

## If you restart Ganache

Start it with the same command and keep the same `ganache-data` folder. Ganache will resume the local chain, preserving its contract and records. Run `npx truffle migrate --network development` after startup; it will only deploy pending migrations and keep the frontend config in sync. If you delete `ganache-data`, you create a new empty chain; redeploy with the same migration command and it will write the new contract address automatically. Records on the old local chain cannot be recovered from the new one.

Do not open `http://127.0.0.1:7545` as a webpage; it is Ganache's RPC endpoint. A 404 for `/favicon.ico` in the Python server log is harmless.
