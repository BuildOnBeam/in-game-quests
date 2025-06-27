# Quest manager

## Deploying the contract and mint

### 1. create a game, fund with at least 100 beam, save the api keys: https://dashboard.beta.onbeam.com/

```sh
# these api keys are from a demo app on testnet, no issue if they become public.
publishable: tWQswQWUHpVhcba0p0exN9CnQcWExR3n
secret: krrE6lBq01eRUG03tKHQWaXWfOunciBV
```

### 2. to execute minting we need an entity to mint with, the api uses profiles for this.

```sh
curl -X 'POST' \
  'https://api.testnet.onbeam.com/v1/profiles' \
  -H 'accept: application/json' \
  -H 'x-api-key: krrE6lBq01eRUG03tKHQWaXWfOunciBV' \
  -H 'Content-Type: application/json' \
  -d '{
  "entityId": "minter",
  "chainId": 13337
}' | jq
```
Store the address and gameId

minterAddress: 0xf36F50Ac9d3F50DB1B576b2D7C87d0c79091Ad95
gameId: cmcbzs49w01pduf01bm3x09qw

```sh
# list the existing profiles (to fetch the minter)
curl -X 'GET' \
  'https://api.testnet.onbeam.com/v1/profiles' \
  -H 'accept: application/json' \
  -H 'x-api-key: krrE6lBq01eRUG03tKHQWaXWfOunciBV' | jq
```

### 3. Clone the repo and get the dependencies

```sh
# clone repo and go to correct branch
git clone git@github.com:BuildOnBeam/in-game-quests.git
cd in-game-quests
git checkout OB-1123-create-factory-for-in-game-quests

# instal foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# RELOAD commandline, or open a new one
forge install
```

### 4. Create a deployment account to deploy and manage the Factory and Questmanager, enter the password

```sh
cast wallet new --password ~/.foundry/keystores/ deployAddress
```
Save the address!!

deployAddress: 0x300D89EbaA3730240B3517DA570Cbc48654551fB

### 5. Fund the wallet with some beam for gas

Just use metamask or similar to put 100 beam on 0x300D89EbaA3730240B3517DA570Cbc48654551fB (deployAddress)

### 6. Deploy the factory (only needed once!)

```sh
forge script script/DeployFactory.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
  --account deployAddress \
  --password password \
  --sender 0x300D89EbaA3730240B3517DA570Cbc48654551fB \
  --broadcast
```
save the factoryAddress: 0xFB7A857e5ab24074c0753FE1f027dB6351400261

### 7. Deploy the QuestManager

```sh
forge script script/CreateQuestManager.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
    --account deployAddress \
  --password password \
  --sender 0x300D89EbaA3730240B3517DA570Cbc48654551fB \
   --sig "run(address,string)" 0xFB7A857e5ab24074c0753FE1f027dB6351400261 cmcbzs49w01pduf01bm3x09qw \
  --broadcast
```

save the questManageraddress: 0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88

### 8. Grant minter to minterAddress

first address -> contractAddress
second address -> minterAddress

```sh
forge script script/GrantRole.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
   --account deployAddress \
  --password password \
  --sender 0x300D89EbaA3730240B3517DA570Cbc48654551fB \
   --sig "run(address,address,string memory)" 0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88 0xf36F50Ac9d3F50DB1B576b2D7C87d0c79091Ad95 "MINTER_ROLE" \
  --broadcast


forge script script/GrantRole.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
   --account deployAddress \
  --password password \
  --sender 0x300D89EbaA3730240B3517DA570Cbc48654551fB \
   --sig "run(address,address,string memory)" 0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88 0xf36F50Ac9d3F50DB1B576b2D7C87d0c79091Ad95 "DEFAULT_ADMIN_ROLE" \
  --broadcast
```

### 9. Grant setUri role, and set the metadata url
```sh
# add role
forge script script/GrantRole.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
   --account deployAddress \
  --password password \
  --sender 0x300D89EbaA3730240B3517DA570Cbc48654551fB \
   --sig "run(address,address,string memory)" 0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88 0xf36F50Ac9d3F50DB1B576b2D7C87d0c79091Ad95 "URI_SETTER_ROLE" \
  --broadcast

# set Uri
forge script script/SetUri.s.sol \
  --rpc-url https://build.onbeam.com/rpc/testnet \
   --account deployAddress \
  --password password \
  --sender 0x300D89EbaA3730240B3517DA570Cbc48654551fB \
   --sig "run(address,string memory)" 0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88 "https://s3.eu-west-1.amazonaws.com/files.weteling.com/metadata/0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88/{id}.json" \
  --broadcast
```

### 10. Validate the contract in the block explorer
Upload the contract + abi here: https://subnets-test.avax.network/tools/manage-contracts/verify/

abi: out/QuestManager.sol/QuestManager.json
contract: src/QuestManager.sol

### 11. Add the contract to beam dashboard
https://dashboard.beta.onbeam.com/games/cmcbzs49w01pduf01bm3x09qw

### 12. Mint

This would be called by the game dev to "achieve" something.

Use the profile of the minter

Function args
1. to address
2. token id
3. amount
4. data (ignore)

```sh
 curl -X 'POST' \
  'https://api.testnet.onbeam.com/v2/transactions/profiles/minter' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -H 'x-api-key: krrE6lBq01eRUG03tKHQWaXWfOunciBV' \
  -d '{
  "interactions": [
    {
      "contractAddress": "0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88",
      "functionName": "mint",
      "functionArgs": ["0x546DaE5A61c801D5Ff3dD5d9026E5418C760E3da", "1", "1", ""],
      "value": ""
    }
  ],
  "optimistic": false,
  "sponsor": true,
  "policyId": null,
  "chainId": 13337
}'
```

## Interact with the contract

### 1. get the privatekey from the deployer

```sh
cast wallet dk deployAddress
```

### 2. add the deployAddress account to metamask

- add account or hardware wallet
- private key and punch it in

### 3. invoke contract calls

- go to: https://xtools-at.github.io/smartcontract-ui/
- sign in with Metamask and deployAddress
- upload the abi: out/QuestManager.sol/QuestManager.json
- and execute contract calls

## Add the Collection to sphere.market

1. make sure you are an admin in sphere, the wallet that deployed the contract.
https://docs.onbeam.com/sdk/sphere/publish-collections

2. go to collections -> create collection and follow the steps.

https://preview.sphere.market/beam-testnet/collection/0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88

## Fetch minted tokens

### Get all the individual mints for a contract

```sh
curl -X 'POST' \
  'https://api.testnet.onbeam.com/v1/automation/activity/assets/0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88' \
  -H 'accept: application/json' \
  -H 'x-api-key: tWQswQWUHpVhcba0p0exN9CnQcWExR3n' \
  -H 'Content-Type: application/json' \
  -d '{
  "limit": 20,
  "types": [
    "mint"
  ],
  "chainId": 13337,
  "continuation": null
}' | jq
```

### Get all token ids that have been minted for a contract (not that handy)

```sh
curl -X 'POST' \
  'https://api.testnet.onbeam.com/v2/assets/0xbE60dace4A1b458bF0f6d8024206e7fb1bF78B88' \
  -H 'accept: application/json' \
  -H 'x-api-key: tWQswQWUHpVhcba0p0exN9CnQcWExR3n' \
  -H 'Content-Type: application/json' \
  -d '{
    "continuation": null,
    "chainId": 13337,
    "minRarityRank": null,
    "maxRarityRank": null,
    "minFloorAskPrice": null,
    "maxFloorAskPrice": null,
    "includeAttributes": false,
    "attributes": null,
    "sortDirection": "asc",
    "sortBy": "floorAskPrice",
    "limit": 20
  }' | jq
```
