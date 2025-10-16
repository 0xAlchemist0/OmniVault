// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/interfaces/IRouter.sol";
interface ISwaphandler is IRouter{

//to add lp to the one pool we need to deposit to we cll mint here in the nft position manager 0x12E66C8F215DdD5d48d150c8f46aD0c6fB0F4406
    //gets quote for swapping a asset on shaodw
 function getAmountsOut(
        uint256 amountIn,
        route[] memory routes
    ) public view returns (uint256[] memory amounts);

//

    //swaps asset based on quote
    function swapExactTokensForTokens( 
    uint256 amountIn, 
    uint256 amountOutMin,
     route[] calldata routes, 
     address to, 
     uint256 deadline) 
     external ensure(deadline)
      returns (uint256[] memory amounts);


      function
}