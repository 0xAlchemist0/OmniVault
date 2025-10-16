// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Composer: orchestrates cross-chain messages
//deposit then swap on shadow
import { VaultComposerSync } from "@layerzerolabs/ovault-evm/contracts/VaultComposerSync.sol";
//to make things easier users deposit omni token  + omni usdc
//bridge usdc then swap on hub chain 
contract OVaultComposer is VaultComposerSync{
    //thi is where we will call and do stuff for th vault when we get amessage from another chain 
    VaultAdater _vault;
    constructor(
        address _vault,
        address _assetOFT,
        address _shareOFT  ) {
            VaultComposerSync(_vault, _assetOFT, _shareOFT);
        }
}


