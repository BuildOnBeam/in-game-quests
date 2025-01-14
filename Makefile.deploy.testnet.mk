-include .env.test
# paths
DEPLOY_CONTRACT_SCRIPT_PATH = script/InGameQuestScript.s.sol

# script method signatures
DEPLOY_CONTRACT_SIG = run()


deploy-testnet:
	forge clean && \
	forge script $(DEPLOY_CONTRACT_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--sig "$(DEPLOY_CONTRACT_SIG)"\
	 	--verify --verifier sourcify	
