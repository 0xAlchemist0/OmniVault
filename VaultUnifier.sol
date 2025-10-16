// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AssetVault} from "./flow/AssetVault.sol";
import {IPoolManager} from "./IPoolManager.sol";
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/CL/periphery/interfaces/INonfungiblePositionManager.sol";
contract VaultUnifier{
    //get both vaults were we can get assets for both 
    AssetVault vaultA;
    AssetVault vaultB;
    IPoolManager poolManager;
    mapping(address => uint256) poolPositions; //we store here and update positions 
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


//returns an array contains the balance of tokena and tokenb use equation then return and we update values
function calculatePostions(calldata[] _position) returns (uint256[]){

}


function getPosition(address _owner){
    (
               address token0,
            address token1,
            int24 tickSpacing,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
    )  = _poolManager.positins(poolPositions[_owner]);
//encode for more efficiency 
    uint256[] positions = calculatePostions(
        abi.encode(
            address token0,
            address token1,
            int24 tickSpacing,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
    )
    );

}


}