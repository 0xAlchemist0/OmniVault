
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//new flow 
//vault adapter uses oftadapter
// Adapter: wraps vault shares as omnichain OFTs
//this will be deployed on other chins
//use router for the route[] struct
import {ISwapHandler} from "./ISwapHandler.sol";
contract VaultAdapter is OFTAdapter, IRouter{
    address public vaultAsset;
    Vault public vault;
    ISwaphandler public dexRouter;

       constructor(
        address _token,
        address _lzEndpoint,
        address _delegate,
        address _router,
        address tokenDeposited
    ) OFTAdapter(_token, _lzEndpoint, _delegate) Ownable(_delegate) {
        vault = token;
        //we set the vaults asset as the _vaultasset
        vaultAsset = vault.asset();
        // /router we set which is wherewe will do swaps and quote obtaining 
        dexRouter = _router;
    }

//aount out min is the _assets from swap and deposit
//routes is struct {from, to, stable}
//from token ur selling, to token you wanna recieve, stable or not 
    function swap(uint256 amountOutMin, route[] calldata routes) {
        uint256[] memory quote = dexRouter.getAmountsOut(); 
    }


//asets should be the amount we are depositing for usdc
    function swapAndDeposit(uint256 _assets){}

}
