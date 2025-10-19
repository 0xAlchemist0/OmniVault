
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//new flow 
//vault adapter uses oftadapter
// Adapter: wraps vault shares as omnichain OFTs
//this will be deployed on other chins
//use router for the route[] struct
import {ISwapHandler} from "./ISwapHandler.sol";
import {VaultUnifier} from "./VaultUnifier.sol";
contract VaultAdapter is OFTAdapter, IRouter{
    address public vaultAsset;
    //this is the asst e convert to wrappd sonic
    //for now we try t use omnichain btc cuz sonic dont got alot of ofts
    address public oAsset = 0x0555e30da8f98308edb960aa94c0db47230d2b9c;
    Vault public vault;
    VaultUnifier public unifiedVault;
    ISwaphandler public dexRouter;
//here we set the endpoint this is what allows us to send and compose the messgaes we recieve 
       constructor(
        address _token,
        address _lzEndpoint,
        address _delegate,
        address _router,
        address _unifiedVault,
        address tokenDeposited
    ) OFTAdapter(_token, _lzEndpoint, _delegate) Ownable(_delegate) {
        vault = _token;
        //we set the vaults asset as the _vaultasset
        vaultAsset = vault.asset();
        // /router we set which is wherewe will do swaps and quote obtaining 
        dexRouter = _router;
        unifiedVault = _unifiedVault;
    }

//aount out min is the _assets from swap and deposit
//routes is struct {from, to, stable}
//from token ur selling, to token you wanna recieve, stable or not 
// /, route[] calldata routes
//private fucntion type means we can call it here in the contract only, users or other contracts cannot call it
    function swap(uint256 _amountInMin)private returns(uint256){
        //create a rotueee struct to pass in when swapping 
        //we assume the pool is true
        route routes = route(oAsset ,vaultAsset, true);
        uint256[] memory quote = dexRouter.getAmountsOut(_amountInMin, routes); 

        unit256 deadline = block.timestamp();
        //might have to calculate slippage for thee asst
        //swap the token 
        dexRouter.swapExactTokensForTokens(amountIn, quote[0], routes, vaultAsset, deadline);
    }
///swap and then send message to transfer to sonic to deposit 

    function getQuote(uint256 amountIn, route[] routes) returns (uint256[] memory){
        uint256[] memory quote = ISwaphandler.getAmountsOut(amountIn, routes);

        return quote;
    }


//asets should be the amount we are depositing for usdc
    function swapAndDeposit(uint256 _assets){
        //the amount recieved from the swap is what we deposit
        uint256 _amountRecieved = swap(_assets);
        // vault.deposit()
    }
//mybe hndale it like this layer zero message s we pass in the type of transaction we do and pass the sender of the message to stor there data in the contracts
}


// deposit dragon oft - > bridge to sonic chain(hub) -> posit into vault 

// deposit btc oft -> bridge to sonic chain (hub) into the native vault contract -> 
