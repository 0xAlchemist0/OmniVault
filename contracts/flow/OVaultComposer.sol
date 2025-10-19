// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Composer: orchestrates cross-chain messages
//deposit then swap on shadow
import { VaultComposerSync } from "@layerzerolabs/ovault-evm/contracts/VaultComposerSync.sol";
import "@layerzerolabs/ovm-integration-interfaces/contracts/lzApp/NonblockingLzApp.sol";

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

//rcieves the message layer zero is sending from another chain 
//target for tm find where this lzrecieve originates from to inherit and use in this contract
  function _lzReceive(
    Origin calldata /*_origin*/,
    bytes32 _guid,
    bytes calldata payload,
    address /*_executor*/,
    bytes calldata /*_extraData*/
) internal override {
    /**
     * @dev Decode the payload based on the expected format from the sender application.
     *      The structure of `payload` depends entirely on how the sender encoded it.
     *      In this case, we assume the sender encoded a string message and a composer address.
     *      If the sender encodes different types or a different order, this decoding must be updated accordingly.
     */
    (string memory _message, address _composedAddress) = abi.decode(payload, (string, address));

    // Store received data in the destination OApp
    data = _message;

    // Send a composed message to the composed receiver using the same GUID
    endpoint.sendCompose(_composedAddress, _guid, 0, payload);
}


//composes the message and sends the message out where it needs to go
//its already built in the VaultComposerSync contract but we override it to o cusotmt things 
//https://github.com/LayerZero-Labs/devtools/blob/main/packages/ovault-evm/contracts/VaultComposerSync.sol
   function lzCompose(
        address _oApp,
        bytes32 /* _guid */,
        bytes calldata _message/* _message */,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) external payable override {
        // Ensure the composed message comes from the correct OApp.
        require(_oApp == oApp, "ComposedReceiver: Invalid OApp");
        require(msg.sender == endpoint, "ComposedReceiver: Unauthorized sender");
        //message should always have the user address that calls the function 
        (address _user) = abi.decode(_message, (address));
        // ... execute logic for handling composed messages
    }
}


//so omposer prepares and sends out message lz recieve recieves it and excecutes instructions