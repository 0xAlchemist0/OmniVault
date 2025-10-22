// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//new flow
//vault adapter uses oftadapter
// Adapter: wraps vault shares as omnichain OFTs
//this will be deployed on other chins
//use router for the route[] struct

// /there wil be two adapters deployrf because each adaper should be unique one vault per adapter due to oftadapters constructor nature
import {ISwapHandler} from "./ISwapHandler.sol";
import {MessagingFee} from "./interfaces/ILayerZeroEndpointV2.sol";

import {VaultUnifier} from "./VaultUnifier.sol";

contract VaultAdapter is OFTAdapter, IRouter, ILayerZeroEndpointV2 {
    mapping(address => uint256) assestsDeposited;
    struct Packet {
        //will fix and store n sperate files  later
        uint32 _dstEid; // destination endpoint ID (chain ID in LayerZero format)
        bytes32 receiver; // address of destination contract (in bytes32 form) this contracts address
        bytes payload; // encoded data you want to send
        bytes32 executor; // usually address(0) unless using custom executor
    }
    //just for now i know its sloppy we will clean when i hav flow set down :( refactor code)
    struct PacketTwo {
        uint64 nonce;
        uint32 srcEid;
        address sender;
        uint32 dstEid;
        bytes32 receiver;
        bytes32 guid;
        bytes message;
    }
    address public vaultAsset;
    //this is the asst e convert to wrappd sonic
    //for now we try t use omnichain btc cuz sonic dont got alot of ofts
    address public oAsset = 0x0555e30da8f98308edb960aa94c0db47230d2b9c;
    Vault vault;
    //does message sending and recieveing
    OVaultComposer oVaultComposer;

    VaultUnifier public unifiedVault;
    ISwaphandler public dexRouter;
    bool isMainAsset;
    uint32 dstEid;
    uint32 srcId;
    address _endpoint;

    //sonic endpoint id 30332
    //here we set the endpoint this is what allows us to send and compose the messgaes we recieve
    constructor(
        address _token,
        address _lzEndpoint,
        address _delegate,
        address _unifiedVault,
        address _router,
        address _oVaultCOmposer,
        bool _isMainAsset,
        address _hubChainId
    ) OFTAdapter(_token, _lzEndpoint, _delegate) Ownable(_delegate) {
        //each vault will have sperate composers
        oVaultCOmposer = _oVaultComposer;
        vault = _token;
        //we set the vaults asset as the _vaultasset from the vault
        vaultAsset = vault.asset();
        // /router we set which is wherewe will do swaps and quote obtaining
        dexRouter = _router;
        unifiedVault = _unifiedVault;
        _isMainAsset = isMainAsset;
        dstEid = _hubChainId;
        //every l0 asset should have this funciton
        _endpoint = vaultAsset.endpoint();
    } //rmember t implement ownble and security check each function when done

    function setOAsset(address _oAsset) external {
        //n withdraw when updated this possibly wont be able to happen everything is fixed system works in a fixed manner
        //over time contracts will be upgraded with an improved flow this is just an initial setup flow
        oAsset = _oAsset;
    }

    //gets current layer zer eid
    //this is the endpoint id from the chain we are depositing for example base -> sonic
    function getEid() returns (uint132) {
        uint132 eid = _endpoint.eid();
        return eid;
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
    struct MessagingParams {
        uint32 dstEid;
        bytes32 receiver;
        bytes message;
        bytes options;
        bool payInLzToken;
    }

    function excecuteCall(
        uint256 _amount,
        address _user,
        bool isWithdraw
    ) external {
        vaultAsset.transferFrom(msg.sender, address(this), _amount);
        bridgeAsset(_amount);
        bytes opt = OptionsBuilder.addExecutorLzReceiveOption(200_000, 0);
        bytes _mess;
        if (isWithdraw) {
            _mess = abi.encodeWithSignature(
                "executeDeposit(uint256, address)",
                _amount,
                _user
            );
        } else {
            _mess = abi.encodeWithSignature(
                "excecuteWithdraw(uint256, address)",
                _amount,
                _user
            );
        }
        MessagingParams _message = MessagingParams({
            dstEid: dstEid,
            reciever: address(this),
            message: "",
            options: opt
        });
        oVaultComposer._lzsend(_message, address(this));
    }

    //we must approve from the assets contract before doing anyything
    function excecuteWithdraw() {
        if (isMainAsset) {}
    }

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
        //transfer assets into this contract bridge using the send function
        //so this the flow transfer the assets into this contract
        //using the oft built in function we send to this contract again but on another chain
        //transfer in here needs spending approval beofr excecutiong

        if (isMainAsset) vault.deposit(_amount, _user);
        else swapAndDeposit(_amount, _user);

        updateDepositedAssets(_amounts, _user);
    }

    function bridgeAsset(uint256 _amount) private {
        //         struct Packet {
        //     uint64 nonce;
        //     uint32 srcEid; //
        //     address sender; //
        //     uint32 dstEid; //
        //     bytes32 receiver; //
        //     bytes32 guid;
        //     bytes message; //
        // }
        //        Packet calldata _packet,
        // bytes calldata _options,
        // bool _payInLzToken
        uint132 srcEid = getEid();
        PacketTwo _message = PacketTwo(
            srcEid, // srceEid
            address(this), // sender
            dstEid, //destination id dstEid
            abi.encode(address(this), address(this), _amount), //message
            false // pay with gas or lz token we pay normal gas of chain
        );

        // in order to send quoteoft we have to store the params in the struct below
        //make structget quote to send message to bridge

        // struct MessagingFee {
        //     uint256 nativeFee;
        //     uint256 lzTokenFee;
        // }

        MessagingFee memory fee = vaultAsset.quoteSend(
            SendParam({
                dstEid: dstEid, // ✅ destination endpoint id
                to: bytes32(uint256(uint160(address(this)))), // ✅ receiver on destination (cast to bytes32)
                amountLD: _amount, // ✅ amount to send
                minAmountLD: _amount, // ✅ min amount (usually same unless slippage)
                extraOptions: "", // ✅ leave empty unless customizing gas limits etc.
                composeMsg: "", // ✅ optional compose data (can be empty)
                oftCmd: ""
            }),
            false
        );
        //message, fees from quote, and refund address
        vaultAsset.send(_message, fee, address(this));
    }

    struct SendParam {
        uint32 dstEid; // Destination endpoint ID.
        bytes32 to; // Recipient address.
        uint256 amountLD; // Amount to send in local decimals.
        uint256 minAmountLD; // Minimum amount to send in local decimals.
        bytes extraOptions; // Additional options supplied by the caller to be used in the LayerZero message.
        bytes composeMsg; // The composed message for the send() operation.
        bytes oftCmd; // The OFT command to be executed, unused in default OFT implementations.
    }

    //asets should be the amount we are depositing for usdc
    function swapAndDeposit(uint256 _assets, address _user) private {
        //the amount recieved from the swap is what we deposit
        //swaps to the asset we need and then deposits
        uint256 _amountRecieved = swap(_assets);
        vault.deposit(_amountRecieved, _user);
    }

    function updateDepositedAssets(uint256 _amounts, address _user) private {
        assestsDeposited[_user] = _amounts;
    }
    //mybe hndale it like this layer zero message s we pass in the type of transaction we do and pass the sender of the message to stor there data in the contracts
}

// deposit dragon oft - > bridge to sonic chain(hub) -> posit into vault

// deposit btc oft -> bridge to sonic chain (hub) into the native vault contract ->
//we have to have a clear flow of things and see how each asset lands in each contract to finnallly be deposited a sa lp
