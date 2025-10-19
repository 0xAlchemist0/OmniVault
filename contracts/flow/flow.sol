// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {OFTCore} from "@layerzerolabs/lz-evm-oft-v2/contracts/OFTCore.sol";
import { VaultComposerSync } from "@layerzerolabs/ovault-evm/contracts/VaultComposerSync.sol";

contract MyVault is ERC4626 {
    constructor(ERC20 _asset) ERC4626(_asset, "Vault", "vSHARE") {}
}



// //OFTADAPTER constructor 
//         address _token,
//         address _lzEndpoint,
//         address _delegate
// Adapter: wraps vault shares as omnichain OFTs
contract OFTAdapter is OFTCore {
    MyVault public vault;

    constructor(address _endpoint, address _vault) OFTCore(_endpoint) {
        vault = MyVault(_vault);
    }

    function depositToVault(uint256 amount, address user) external {
        //use safetransferfrom to deposit into contract then we call the layer zero fucntion  send to send the deposited funds to another chain and swap them 
        vault.deposit(amount, user); // actual deposit on hub
    }

    function redeemFromVault(uint256 shares, address user) external {
        vault.redeem(shares, user, user); // actual withdrawal
    }
}

// Composer: orchestrates cross-chain messages
contract VaultComposerSync is OFTCore {
    OFTAdapter public adapter;

    constructor(address _endpoint, address _adapter) OFTCore(_endpoint) {
        adapter = OFTAdapter(_adapter);
    }

    function _lzReceive(
        uint32 srcEid,
        bytes32 sender,
        bytes calldata payload
    ) internal override {
        (address user, uint256 amount, bool isDeposit) = abi.decode(payload, (address, uint256, bool));
        if (isDeposit) adapter.depositToVault(amount, user);
        else adapter.redeemFromVault(amount, user);
    }
}
/////////////////////////////////////////////////
//The Fix: If you’re not modifying the input, use calldata. It avoids the copy step and keeps things lean.


//new flow 
//vault adapter uses oftadapter
// Adapter: wraps vault shares as omnichain OFTs
//this will be deployed on other chins
//use router for the route[] struct
contract VaultAdapter is OFTAdapter, IRouter{
    address public _vaultAsset;
    Vault public _vault;
       constructor(
        address _token,
        address _lzEndpoint,
        address _delegate
    ) OFTAdapter(_token, _lzEndpoint, _delegate) Ownable(_delegate) {
        _vault = token;
        //we set the vaults asset as the _vaultasset
        _vaultAsset = _vault.asset();
    }

    function swap(_a)

//asets should be the amount we are depositing for usdc
    function swapAndDeposit(uint256 _assets, ){}

}

// Composer: orchestrates cross-chain messages
//deposit then swap on shadow

//to make things easier users deposit omni token  + omni usdc
//bridge usdc then swap on hub chain 
contract OVaultComposer is VaultComposerSync{
    //thi is where we will call and do stuff for th vault when we get amessage from another chain 
    VaultAdater _vult;
    constructor(
        address _vault,
        address _assetOFT,
        address _shareOFT  ) {
            VaultComposerSync(_vault, _assetOFT, _shareOFT);
        }
}


