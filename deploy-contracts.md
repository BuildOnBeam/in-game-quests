# Deploy Contracts:

## Setup

- clone repo
- run `forge install`

## Install Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Create a wallet

```
cast wallet new
```

This will prompt you to enter a password to encrypt the private key.

The output will include:

A new Ethereum address.

The private key (displayed only once, so save it securely if needed).

The path to the encrypted keystore file (by default, saved in ~/.foundry/keystores).

Example Output:

```
Enter password:
Successfully created new keypair.
Address:     0x123...abc
Private Key: 0x456...def
Keystore was saved to: ~/.foundry/keystores/<filename>

```

## Deploy Factory

```
forge script script/DeployFactory.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
  --account youraccount \
  --password yourpassword \
  --sender youraddress \
  --broadcast
```

## Deploy QuestManager

```
forge script script/CreateQuestManager.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
    --account youraccount \
  --password yourpassword \
  --sender youraddress \
   --sig "run(address,string)" factoryAddress gameId \
  --broadcast
```

## Grant Minter Role to game dev

```
forge script script/GrantMinterRole.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
   --account youraccount \
  --password yourpassword \
  --sender youraddress \
   --sig "run(address,address)" QuestManagerAddress granteeAddress \
  --broadcast
```

## Next Steps

Add the QuestManager to the game dashboard

## Mint Achievement from beam API

```
 curl -X 'POST' \
  'https://api.testnet.onbeam.com/v2/transactions/profiles/lorenza' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'x-api-key: the secret key of the game' \
  -d '{
  "interactions": [
    {
      "contractAddress": "questmanager",
      "functionName": "mint",
      "functionArgs": ["questManagerAddress", "token id", "amount", ""],
      "value": ""
    }
  ],
  "optimistic": false,
  "sponsor": true,
  "policyId": null,
  "chainId": 13337
}'
```
