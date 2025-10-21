// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Composer: orchestrates cross-chain messages
//deposit then swap on shadow
import {VaultComposerSync} from "@layerzerolabs/ovault-evm/contracts/VaultComposerSync.sol";
import "@layerzerolabs/ovm-integration-interfaces/contracts/lzApp/NonblockingLzApp.sol";
import {ILayerZeroReceiver} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroReceiver.sol";

//to make things easier users deposit omni token  + omni usdc
//bridge usdc then swap on hub chain
//deploy twice for both vaults
contract OVaultComposer is ILayerZeroReceiver, VaultComposerSync {
    //thi is where we will call and do stuff for th vault when we get amessage from another chain
    VaultAdater vault;

    constructor(address _vault, address _assetOFT, address _shareOFT) {
        VaultComposerSync(_vault, _assetOFT, _shareOFT);
        vault = _vault;
    }

    //message should include is main asset we only have to deploy one of these and it works with both
    //rcieves the message layer zero is sending from another chain
    //target for tm find where this lzrecieve originates from to inherit and use in this contract
    function lzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) external override {
        //here is basically an event listener then mesage gets passed on to compose to excecute whatever needs to be done
        lzCompose(address(this), _payload);
        //onl gotta pass in the impartant stuff it doesnt call compose immidiatley it quotes then calls compose the rest of the params l0 fills it p
    }

    //composes the message and sends the message out where it needs to go
    //its already built in the VaultComposerSync contract but we override it to o cusotmt things
    //https://github.com/LayerZero-Labs/devtools/blob/main/packages/ovault-evm/contracts/VaultComposerSync.sol
    function lzCompose(
        address _composeSender, // The OFT used on refund, also the vaultIn token.
        bytes32 _guid,
        bytes calldata _message, // expected to contain a composeMessage = abi.encode(SendParam hopSendParam,uint256 minMsgValue)
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) external payable override {
        // Ensure the composed message comes from the correct OApp.
        require(_oApp == oApp, "ComposedReceiver: Invalid OApp");
        require(
            msg.sender == endpoint,
            "ComposedReceiver: Unauthorized sender"
        );
        //this flow cant work because we do two things withdraw and depoit we need to do custom function calls in he ayload
        //sholuld be how we work with the messaging system
        // bytes memory payload = abi.encodeWithSignature(
        //     "handleDeposit(address,uint256)",
        //     msg.sender,
        //     amount
        // );
        //calls custom function call to excecute what it has to excecute
        bool success = vault.call(_message);
    }
}

//so omposer prepares and sends out message lz recieve recieves it and excecutes instructions
