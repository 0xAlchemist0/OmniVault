// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AssetVault} from "./flow/AssetVault.sol";
import {IPoolManager} from "./IPoolManager.sol";
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/CL/periphery/interfaces/INonfungiblePositionManager.sol";
import { UD60x18, ud } from "@prb/math/src/UD60x18.sol";
contract VaultUnifier{

    struct Position {
    address token0;
    address token1;
    int24 tickSpacing;
    int24 tickLower;
    int24 tickUpper;
    uint128 liquidity;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
    uint128 tokensOwed0;
    uint128 tokens;
    uint160 sqrtPriceX96;
    int24 tick;
    uint16 observationIndex;
    uint16 observationCardinality;
    uint16 observationCardinalityNext;
    uint8 feeProtocol;
    bool unlocked;
    }

    //get both vaults were we can get assets for both 
    AssetVault vaultA;
    AssetVault vaultB;
    IPoolManager poolManager;
    IDragonPool pool;
    mapping(address => uint256) poolPositions; //we store here and update positions 
//wunifies both vaults vaults to perform the lp depositt
    constructor(address _vaultA, address vaultB, address _poolManager){
    vaultA = _vaultA;
    vaultB = _vaultB;
    poolManager = _poolManager;
}

//this is what is returned from the quote we use this so we dont have to write a shit ton of code
// /prolly better t put in another file 

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
        // uint256 deadline;PP
//very layer zero message should pass in the sender of the transaction this way e can check nd store each users info properly and their positons
function addLiquidity(MintParams calldata params, address sender){

    //we set the mapping owner => positionID
    poolPositions[sender] = poolManager.mint(params);
}

//uint - positive, int- both 
//returns an array contains the balance of tokena and tokenb use equation then return and we update values
//calldta type means the valu is read only no copy is made most efficient and heapest
function calculatePostions(bytes calldata _postionEncoded) returns (uint256[]){
   //eveythkng will be in one struct 
   (Position _position) = abi.decode(_postionEncoded , (Position));
   uint256 p_current = _position.sqrtPriceX96/ 2**96;
   UD60x18 p_lower =  UD60x18.intoUD60x18(10001 ** _position.tickLower);


}

//follows th shadowswap dex fucntions 
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
   );
 = poolManager.position(poolManager[_owner]);
  (
     
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext,
        uint8 feeProtocol,
        bool unlocked
          
  ) = pool.slot0();


  Position _position = Position(
            token0,
             token1,
             tickSpacing,
             tickLower,
             tickUpper,
             liquidity,
             feeGrowthInside0LastX128,
             feeGrowthInside1LastX128,
             tokensOwed0,
             tokensOwed1,
             sqrtPriceX96,
             tick,
             observationIndex,
             observationCardinality,
             observationCardinalityNext,
             feeProtocol,
             unlocked
  )



 uint256[] position = calculatePositions(abi.encode((_position)));
}


}