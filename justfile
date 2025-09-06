default:
  @just --choose

static-analysis:
  slither . --config-file slither.config.json

deploy:
  forge script script/Deploy.s.sol --rpc-url arbitrum-sepolia --sender 0x25Fbb765998134400f6e2D4191e89C37dB40fa98 --account eth-warsaw-2025 --broadcast --verify