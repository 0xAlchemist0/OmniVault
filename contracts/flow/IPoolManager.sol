// SPDX-License-Identifier: GPL-2.0-or-later

// /10-23 left off herere
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
    //collect fees earned and get returned the fees earned from vault a aset and vaultb asset
    function collect(
        CollectParams calldata params
    )
        external
        payable
        override
        isAuthorizedForToken(params.tokenId)
        returns (uint256 amount0, uint256 amount1);

    //adds liquidity to te position
    function increaseLiquidity(
        IncreaseLiquidityParams calldata params
    )
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (uint128 liquidity, uint256 amount0, uint256 amount1);

    function burn(
        uint256 tokenId
    ) external payable override isAuthorizedForToken(tokenId);

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

    //tthis adds liquidity and mints a new nft returns the token id here with this token id we can manage users postions
    function mint(
        MintParams calldata params
    )
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    function positions(
        uint256 tokenId
    )
        external
        view
        override
        returns (
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

    //this handles to see the current position of the user fom the lp deposit
    //token0 is vulta, token1 is vaultB
    //           token0   address :  0x039e2fB66102314Ce7b64Ce5Ce3E5183bc94aD38
    //   token1   address :  0x69D72992Bfff03f0eBe66108eC281f96D8777777
    //   tickSpacing   int24 :  200
    //   tickLower   int24 :  -16400
    //   tickUpper   int24 :  53000
    //   liquidity   uint128 :  729837194047681127197841
    //   feeGrowthInside0LastX128   uint256 :  0
    //   feeGrowthInside1LastX128   uint256 :  0
    //   tokensOwed0   uint128 :  0
    //   tokensOwed1   uint128 :  0

    //given this use this equation to calculate the new balances the user has in the pool
    /*
  Given:
    L = liquidity of your position
    P_current = current sqrt price of the pool (sqrt(token1/token0))
  this   P_current = uint256(sqrtPriceX96) / 2**96; // approximate
    P_lower   = sqrt price at tickLower
    P_upper   = sqrt price at tickUpper

  Formulas:

  // Amount of token0 in position
  amount0 = L * (P_upper - P_current) / (P_current * P_upper)

  // Amount of token1 in position
  amount1 = L * (P_current - P_lower)

  Notes:
  - P_current, P_lower, P_upper are all square roots of the actual prices.
  - tokensOwed0 and tokensOwed1 are additional unclaimed fees that can be added if > 0.
  - To get final token amounts, make sure units match (usually in wei for ERC20 tokens).
*/
}

//increase liquidity, decrase liquidity, Positon nft contract ->

// gotta make a good secure system to amange all of this the contract will hold all ositionsso u gotta mange how it handles withrws etc

//cell structure and fucntion
