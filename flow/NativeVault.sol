//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC4626.sol";

contract DragonVault is ERC4626 {
    // a mapping that checks if a user has deposited the token
    //seems like strign balances locally is beter 
    mapping(address => uint256) public shareHolder;
//handles dragon deposits 
    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset, _name, _symbol) {}
//max withdraw get share abalances of user, how much they have deposited
    /**
     * @notice function to deposit assets and receive vault tokens in exchange
     * @param _assets amount of the asset token
     */
    //  Sonic (hub) is the main vault. It’s where the real tokens are kept and where the real deposits and withdrawals happen.
    function _deposit(uint _assets) public {
        // checks that the deposited amount is greater than zero.
        require(_assets > 0, "Deposit less than Zero");
        // calling the deposit function from the ERC-4626 library to perform all the necessary functionality
        deposit(_assets, msg.sender);
        // Increase the share of the user
        shareHolder[msg.sender] += _assets;
    }

    /**
     * @notice Function to allow msg.sender to withdraw their deposit plus accrued interest
     * @param _shares amount of shares the user wants to convert
     * @param _receiver address of the user who will receive the assets
     */
    function _withdraw(uint _shares, address _receiver) public {
        // checks that the deposited amount is greater than zero.
        require(_shares > 0, "withdraw must be greater than Zero");
        // Checks that the _receiver address is not zero.
        require(_receiver != address(0), "Zero Address");
        // checks that the caller is a shareholder
        require(shareHolder[msg.sender] > 0, "Not a share holder");
        // checks that the caller has more shares than they are trying to withdraw.
        require(shareHolder[msg.sender] >= _shares, "Not enough shares");


        // calling the redeem function from the ERC-4626 library to perform all the necessary functionality
        redeem(_shares, _receiver, msg.sender);
        // Decrease the share of the user
        shareHolder[msg.sender] -= _shares;
    }

    // returns total number of assets
    //returns total shares that have been minted by every user of the contract 
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    // returns total balance of user
    //balance of tokens user has balance of asset we can deposit into the vault 
    function totalAssetsOfUser(address _user) public view returns (uint256) {
        return asset.balanceOf(_user);
    }
}//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC4626.sol";

contract NativeVault is ERC4626 {
    //just intialize we call the vaults functions i n the adapterhere we inherit the contract
  constructor(ERC20 _token) ERC4626(_token){}
}

//chapter 5 chapter 4 
//wraps
contract NativeVaultAdapter is OFTAdapter{
    AssetVault public vault;


    constructor 
}


