-include .env
# paths
DEPLOY_CONTRACT_SCRIPT_PATH = script/InGameQuestScript.s.sol
GRANT_ADMIN_CONTRACT_SCRIPT_PATH = script/GrantAdminRole.s.sol

# script method signatures
DEPLOY_CONTRACT_SIG = run()
GRANT_ADMIN_CONTRACT_SIG = run()


deploy-testnet:
	forge clean && \
	forge script $(DEPLOY_CONTRACT_SCRIPT_PATH) \
		--sender 0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--password 123 \
		--sig "$(DEPLOY_CONTRACT_SIG)"\
	 	--verify --verifier sourcify



grant-admin:
	forge clean && \
	forge script $(GRANT_ADMIN_CONTRACT_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--password 123 \
		--sig "$(GRANT_ADMIN_CONTRACT_SIG)" \	

