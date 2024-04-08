-include .env

account-store:
	cast wallet import defaultKey --interactive 

deploy-local:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url http://localhost:8545 --account defaultKey --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast -vvvv

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $SEPOLIA_RPC_URL --account defaultKey --sender 0x48f68cB94630e05139BC91bB72de9D124013aE24 --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv