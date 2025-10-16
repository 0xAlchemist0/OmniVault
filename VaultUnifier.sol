// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {DragonVault} from './Dragonvault.sol';
import {NativeVault} from './NativeVault.sol';
import {IPoolManager} from "./IPoolManager.sol";
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/CL/periphery/interfaces/INonfungiblePositionManager.sol";
contract VaultUnifier{
    //get both vaults were we can get assets for both 
    DragonVault vaultA;
    NativeVault vaultB;
    IPoolManager poolManager;
    mapping(address => uint256) poolPositions;
//wunifies both vaults vaults to perform the lp depositt
constructor(address _vaultA, address vaultB, address _poolManager){
vaultA = _vaultA;
vaultB = _vaultB;
poolManager = _poolManager;
}
//mint parms struct
//     address token0;
        // address token1;
        // int24 tickSpacing;
        // int24 tickLower;
        // int24 tickUpper;
        // uint256 amount0Desired;
        // uint256 amount1Desired;
        // uint256 amount0Min;
        // uint256 amount1Min;
        // address recipient;
        // uint256 deadline;
//very layer zero message should pass in the sender of the transaction this way e can check nd store each users info properly and their positons
function addLiquidity(MintParams calldata params, address sender){
    poolPositions[sender] = poolManager.mint(params);
}

}