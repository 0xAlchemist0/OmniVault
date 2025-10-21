// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//new flow
//vault adapter uses oftadapter
// Adapter: wraps vault shares as omnichain OFTs
//this will be deployed on other chins
//use router for the route[] struct

// /there wil be two adapters deployrf because each adaper should be unique one vault per adapter due to oftadapters constructor nature
import {ISwapHandler} from "./ISwapHandler.sol";
import {VaultUnifier} from "./VaultUnifier.sol";

contract VaultAdapter is OFTAdapter, IRouter {
    address public vaultAsset;
    //this is the asst e convert to wrappd sonic
    //for now we try t use omnichain btc cuz sonic dont got alot of ofts
    address public oAsset = 0x0555e30da8f98308edb960aa94c0db47230d2b9c;
    Vault vault;

    VaultUnifier public unifiedVault;
    ISwaphandler public dexRouter;
    bool isMainAsset;

    //here we set the endpoint this is what allows us to send and compose the messgaes we recieve
    constructor(
        address _token,
        address _lzEndpoint,
        address _delegate,
        address _unifiedVault,
        address _router,
        bool _isMainAsset
    ) OFTAdapter(_token, _lzEndpoint, _delegate) Ownable(_delegate) {
        vault = _token;
        //we set the vaults asset as the _vaultasset from the vault
        vaultAsset = vault.asset();
        // /router we set which is wherewe will do swaps and quote obtaining
        dexRouter = _router;
        unifiedVault = _unifiedVault;
        _isMainAsset = isMainAsset;
    } //rmember t implement ownble and security check each function when done

    function setOAsset(address _oAsset) external {
        //n withdraw when updated this possibly wont be able to happen everything is fixed system works in a fixed manner
        //over time contracts will be upgraded with an improved flow this is just an initial setup flow
        oAsset = _oAsset;
    }

    //aount out min is the _assets from swap and deposit
    //routes is struct {from, to, stable}
    //from token ur selling, to token you wanna recieve, stable or not
    // /, route[] calldata routes
    //private fucntion type means we can call it here in the contract only, users or other contracts cannot call it
    function swap(uint256 _amountInMin) private returns (uint256) {
        //create a rotueee struct to pass in when swapping
        //we assume the pool is true
        route routes = route(oAsset, vaultAsset, true);
        uint256[] memory quote = dexRouter.getAmountsOut(_amountInMin, routes);

        unit256 deadline = block.timestamp();
        //might have to calculate slippage for thee asst
        //swap the token
        dexRouter.swapExactTokensForTokens(
            amountIn,
            quote[0],
            routes,
            vaultAsset,
            deadline
        );
    }

    ///swap and then send message to transfer to sonic to deposit

    // function getQuote(
    //     uint256 amountIn,
    //     route[] routes
    // ) public returns (uint256[] memory) {
    //     uint256[] memory quote = ISwaphandler.getAmountsOut(amountIn, routes);

    //     return quote;
    // }

    //omnivault
    //mainasset = omnidragon
    //not maintoken ot omnidragon so its a layer zero token like usdc
    //how it works funds from the l0 send message funds are bridged and sent to sonic the adapter
    //handles this stuff and funds
    //if its the oasset it swaps into the token for the vault if its not main token(isMainToken)
    //this function for detecting the  kind of asset we are depositing if its not our dragon token we swap and then deposit
    function excecuteDeposit(uint256 _amount, address _user) external {
        // vaultAsset.safeTransferFrom();
        //we need _user to store how much they hold in the vault
        //deposits the asset into the vault
        if (isMainAsset) vault.deposit(_amount, _user);
        else swapAndDeposit(_amount, _user);
    }

    //asets should be the amount we are depositing for usdc
    function swapAndDeposit(uint256 _assets, address _user) private {
        //the amount recieved from the swap is what we deposit
        //swaps to the asset we need and then deposits
        uint256 _amountRecieved = swap(_assets);
        vault.deposit(_amountRecieved, _user);
    }
    //mybe hndale it like this layer zero message s we pass in the type of transaction we do and pass the sender of the message to stor there data in the contracts
}

// deposit dragon oft - > bridge to sonic chain(hub) -> posit into vault

// deposit btc oft -> bridge to sonic chain (hub) into the native vault contract ->
//we have to have a clear flow of things and see how each asset lands in each contract to finnallly be deposited a sa lp
