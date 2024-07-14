## Starknet Automated Market Makers

### Installation

1. Add the Starknet Foundry plugin:

```shell
asdf plugin add starknet-foundry
```

2. Install the latest version of Starknet Foundry:

```shell
asdf install starknet-foundry 0.26.0
```

3. Set the global version of Starknet Foundry to 0.26.0:

```shell
asdf global starknet-foundry 0.26.0
```

4. Verify the installation:

```sh
snforge --version
sncast --version
```

### Initialize a New Project

1. Use Starknet Foundry to start a new project

```sh
snforge init starknet_amm
cd starknet_amm
```

2. Create a new snfoundry.toml file.

### Add Account Profile

1. Run the following command to add an account profile:

```sh
sncast --url https://free-rpc.nethermind.io/sepolia-juno/v0_7 \
account add \
-n wolf \
-a ${address} \
-t [oz, argent, braavos] \
-c ${class_hash} \
--private-key ${private_key} \
--add-profile default
```

### Declare ERC20 Token

1. Declare the ERC20 Token contract:

```sh
sncast declare --contract-name MyERC20Token
```

### Deploy Tokens

#### Deploy My USDC

1. Deploy the My USDC token:

```sh
sncast deploy \
--class-hash 0x037db7443c788ffdd2d12bdc687f6588b83209b3bcc9ba69dc191e8e9efd6d67 \
-c 0 470121931875 5 0 470121931875 5 0x3635c9adc5dea00000 0x0 ${your_account-address}
```

#### Deploy My ETH

1. Deploy the My ETH token:

```sh
sncast deploy \
--class-hash 0x037db7443c788ffdd2d12bdc687f6588b83209b3bcc9ba69dc191e8e9efd6d67 \
-c 0 1835365480 4 0 1835365480 4 0x8ac7230489e80000 0x0 ${your_account_address}
```

### Declare and Deploy AMM

1. Declare the AMM contract:

```sh
sncast declare --contract-name StarknetAMM
```

2. Deploy the AMM contract:

```sh
sncast deploy \
--class-hash 0x1a9852fdbc09d3b8b70f2b8c4af0a28bfd0c3fb4c70b5065c008492ec13f056 \
-c ${ETH_token_address} ${USDC_token_address}
```

### Token Operations

#### Approve AMM Contract to Transfer USDC

1. Authorize the AMM contract to transfer 1000 USDC:

```sh
sncast invoke \
--contract-address ${USDC_token_address} \
--function approve \
--calldata ${AMM_token_address} 0x3635c9adc5dea00000 0x0
```

#### Approve AMM Contract to Transfer ETH

1. Authorize the AMM contract to transfer 10 ETH:

```sh
sncast invoke \
--contract-address ${ETH_token_address} \
--function add_liquidity \
--calldata ${AMM_token_address} 0x8ac7230489e80000 0x0
```

### Add Liquidity

1. Add liquidity to the AMM contract:

```sh
sncast invoke \
--contract-address ${AMM_token_address} \
--function add_liquidity \
--calldata 0x8ac7230489e80000 0x0 0x3635c9adc5dea00000 0x0
```

### Swap 2 ETH for 250 USDC

```sh
sncast invoke \
--contract-address ${AMM_token_address} \
--function swap \
--calldata ${USDC_token_address} 0x0d8d726b7177a80000 0x0
```
