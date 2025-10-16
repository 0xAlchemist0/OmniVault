// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {DragonVault} from './Dragonvault.sol';
import {NativeVault} from './NativeVault.sol';

contract VaultUnifier{
    //get both vaults were we can get assets for both 
    DragonVault vaultA;
    NativeVault vaultB;
    mapping(address => uint256) poolPositions;
//wunifies both vaults vaults to perform the lp depositt
constructor(address _vaultA, address vaultB){
vaultA = _vaultA;
vaultB = _vaulyB;
}

function

}