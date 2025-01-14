# In Game Quest Contract

## Summary

1. [Description](#description)
2. [Features](#features)
3. [Token ID](#token-id)
4. [Running Tests](#running-tests)
5. [How To Deploy The Contract](#how-to-deploy-the-contract)
6. [Deployed Contract](#deployed-contract)

# Description

A Solidity smart contract implementing soulbound ERC1155 tokens for in-game quests. This contract ensures that tokens representing quests or achievements cannot be transferred or approved for transfer, effectively making them soulbound.

## Features

- Soulbound Tokens: Tokens cannot be transferred approved for transfer or burned by anyone, including the owner.
- Access Control: Utilizes OpenZeppelin's AccessControl for role-based permissions.
- Minting: Only addresses with the MINTER_ROLE can mint new tokens or batches of tokens. In order to get this role, an admin should grant it.
- URI Setting: Only addresses with the URI_SETTER_ROLE can update the token URI.

## Token ID

mint and mintBatch functions accept an Id that will be constructed off-chain this way:

    - first 4 cypher is the game id, eg: 1234
    - whatever is after is the quest id, eg: 0001
    - the resulting id will be: #12340001

## Running Tests

To run tests, run the following command

```bash
    make test-all
```

## How To Deploy The Contract

you need to add an account [using cast wallet import](https://book.getfoundry.sh/reference/cast/cast-wallet-import), give it a name and add it to the .env.testnet file (or the .env.mainnet, to deploy on mainnet), then run

> the command below is to deploy on testnet. Commands to deploy on mainnet will come shortly.

```bash
    make deploy-testnet
```

## Deployed Contract

- testnet: [0x5BA894A5A054c7903Bc31EC83e4eFE019dD0d27C](https://subnets-test.avax.network/beam/address/0x5BA894A5A054c7903Bc31EC83e4eFE019dD0d27C?tab=code)
