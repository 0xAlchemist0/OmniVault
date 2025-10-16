
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.26;
// 0x12E66C8F215DdD5d48d150c8f46aD0c6fB0F4406 for increasing and decreasing lp positons on the specific pool
//token id for the current positon of the pool we want to depoit to 
// liquidity CA: 0x12E66C8F215DdD5d48d150c8f46aD0c6fB0F4406  POOLiD:1055045(specific pool id we will be depositing into )
// //pool ca 0xdF7f1B58F7dF627AFAa248D628795B1E9D1963Fb
//     struct IncreaseLiquidityParams {
//         uint256 tokenId;
//         uint256 amount0Desired;
//         uint256 amount1Desired;
//         uint256 amount0Min;
//         uint256 amount1Min;
//         uint256 deadline;
//     }
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/CL/periphery/interfaces/INonfungiblePositionManager.sol";
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/CL/periphery/base/PeripheryValidation.sol";
interface IPoolManager is IncreaseLiquidityParams {
    //adds liquidity to te position 
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (uint128 liquidity, uint256 amount0, uint256 amount1);

//decrease withdrawTokens from pool

    // struct DecreaseLiquidityParams {
    //     uint256 tokenId;
    //     uint128 liquidity;
    //     uint256 amount0Min;
    //     uint256 amount1Min;
    //     uint256 deadline;
    // }
// both tokens has to be withdwan certain percentage ex: 75% 
    function decreaseLiquidity(
        DecreaseLiquidityParams calldata params
    )
        external
        payable
        override
        isAuthorizedForToken(params.tokenId)
        checkDeadline(params.deadline)
        returns (uint256 amount0, uint256 amount1);
}

//increase liquidity, decrase liquidity, Positon nft contract -> 

// gotta make a good secure system to amange all of this the contract will hold all ositionsso u gotta mange how it handles withrws etc